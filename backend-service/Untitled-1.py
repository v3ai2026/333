if __name__ == '__main__':
    logger.info(f"🚀 启动 moda.STUDIO 后端服务 v2.0")
    logger.info(f"   模型: {MODEL_ID}")
    logger.info(f"   缓存: {MAX_CACHE_SIZE} items, TTL {CACHE_TTL}s")
    app.run(host='0.0.0.0', port=PORT, debug=False)
