FROM ollama/ollama:0.3.14

ARG MODEL_NAME
ARG BASE_MODEL
ARG ENABLE_JP

WORKDIR /workspace

COPY modelfiles/ ./modelfiles/
COPY prompts/ ./prompts/

# ---- Modelfile をテンプレート展開する処理 ----
# jp.modelfile / en.modelfile の {{BASE_MODEL}} を置換
RUN sed "s/{{BASE_MODEL}}/${BASE_MODEL}/g" modelfiles/jp.modelfile > modelfiles/jp.modelfile.rendered && \
    sed "s/{{BASE_MODEL}}/${BASE_MODEL}/g" modelfiles/en.modelfile > modelfiles/en.modelfile.rendered

# ---- モデルをビルド ----
RUN nohup ollama serve >/tmp/ollama.log 2>&1 & \
    sleep 4 && \
    if [ "$ENABLE_JP" = "true" ]; then \
        echo "Building Japanese model..."; \
        ollama create "$MODEL_NAME" -f modelfiles/jp.modelfile.rendered; \
    else \
        echo "Building English model..."; \
        ollama create "$MODEL_NAME" -f modelfiles/en.modelfile.rendered; \
    fi && \
    pkill ollama
