from fastapi import FastAPI, HTTPException
import pandas as pd
import numpy as np
from transformers import BertTokenizer, BertModel
import torch
from sklearn.metrics.pairwise import cosine_similarity

app = FastAPI()


@app.get("/")
def read_root():
    return {"gezBot": "AI"}
