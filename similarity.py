import sys
import json
import torch
import torch.nn.functional as F
from sentence_transformers import SentenceTransformer, CrossEncoder
from scipy.spatial.distance import cosine
import logging

# Configure logging
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

bi_encoder = SentenceTransformer('sentence-transformers/all-mpnet-base-v2')
cross_encoder = CrossEncoder('cross-encoder/ms-marco-MiniLM-L-6-v2')

def preprocess_resume(resume_json):
    logging.debug("Preprocessing resume data...")
    parts = [
        resume_json.get("summary", ""),
        "Skills: " + ", ".join(resume_json.get("skills", []))
    ]
    for exp in resume_json.get("experience", []):
        job_title = exp.get("title", "")
        company = exp.get("company", "")
        description = exp.get("description", "")
        if isinstance(description, list):
            description = " ".join(description)
        experience_str = f"{job_title} at {company}: {description}"
        parts.append(experience_str)
    logging.debug(f"Processed resume: {parts}")
    return " ".join(parts)

def compute_similarity_biencoder(resume_text, job_text):
    logging.debug("Computing similarity using Bi-Encoder...")
    resume_embedding = bi_encoder.encode(resume_text, convert_to_tensor=True)
    job_embedding = bi_encoder.encode(job_text, convert_to_tensor=True)
    score = 1 - cosine(resume_embedding.cpu(), job_embedding.cpu())
    logging.debug(f"Bi-Encoder similarity score: {score}")
    return float(score)

def compute_similarity_crossencoder(resume_text, job_text):
    logging.debug("Computing similarity using Cross-Encoder...")
    raw_score = cross_encoder.predict([(resume_text, job_text)])[0]
    normalized_score = float(F.sigmoid(torch.tensor(raw_score)))
    logging.debug(f"Cross-Encoder raw score: {raw_score}, normalized score: {normalized_score}")
    return normalized_score

def boost_score(score, min_percent=10):
    logging.debug("Boosting score...")
    boosted = min_percent + (100 - min_percent) * score
    logging.debug(f"Boosted score: {boosted}")
    return round(boosted, 2)

if __name__ == "__main__":
    try:
        # Log the inputs
        logging.info("Starting similarity calculation...")

        resume_json = json.loads(sys.argv[1])
        job_description_json = json.loads(sys.argv[2])

        resume_text = preprocess_resume(resume_json)
        job_text = job_description_json.get("jobDescription", "")

        bi_score = compute_similarity_biencoder(resume_text, job_text)
        cross_score = compute_similarity_crossencoder(resume_text, job_text)

        final_score = (bi_score + cross_score) / 2
        boosted_score = boost_score(final_score)

        # Logging
        logging.info(f"Bi-Encoder score: {round(bi_score*100, 2)}%")
        logging.info(f"Cross-Encoder score: {round(cross_score*100, 2)}%")

        # Final boosted score to stdout
        print(boosted_score)

    except Exception as e:
        logging.error(f"Error: {e}")
        sys.exit(1)
