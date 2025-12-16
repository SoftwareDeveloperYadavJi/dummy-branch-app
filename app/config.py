import os
import json
import logging
from logging import Formatter

class JSONFormatter(Formatter):
    """Structured JSON log formatter for production"""
    def format(self, record):
        log_data = {
            'timestamp': self.formatTime(record, self.datefmt),
            'level': record.levelname,
            'logger': record.name,
            'message': record.getMessage(),
            'module': record.module,
            'function': record.funcName,
            'line': record.lineno,
        }
        
        # Add exception info if present
        if record.exc_info:
            log_data['exception'] = self.formatException(record.exc_info)
        
        # Add extra fields if present
        if hasattr(record, 'extra_fields'):
            log_data.update(record.extra_fields)
        
        return json.dumps(log_data)

class Config:
    FLASK_ENV: str = os.getenv("FLASK_ENV", "development")
    PORT: int = int(os.getenv("PORT", "8000"))
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "postgresql+psycopg2://postgres:postgres@db:5432/microloans",
    )
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO")
    LOG_FORMAT: str = os.getenv("LOG_FORMAT", "text")  # 'text' or 'json'
    
    @staticmethod
    def setup_logging(app):
        """Configure logging based on environment"""
        log_level = getattr(logging, Config.LOG_LEVEL.upper(), logging.INFO)
        
        # Remove default handlers
        for handler in app.logger.handlers[:]:
            app.logger.removeHandler(handler)
        
        # Create handler
        handler = logging.StreamHandler()
        handler.setLevel(log_level)
        
        # Set formatter based on LOG_FORMAT
        if Config.LOG_FORMAT == "json":
            formatter = JSONFormatter()
        else:
            # Standard text formatter
            formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
            )
        
        handler.setFormatter(formatter)
        app.logger.addHandler(handler)
        app.logger.setLevel(log_level)
        
        # Reduce noise from some libraries
        logging.getLogger('werkzeug').setLevel(logging.WARNING)
        logging.getLogger('sqlalchemy.engine').setLevel(logging.WARNING)
