"""Basic health endpoint tests"""
import pytest
from app import create_app


@pytest.fixture
def client():
    """Create a test client"""
    app = create_app()
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client


def test_health_endpoint(client):
    """Test the health endpoint returns ok status"""
    response = client.get('/health')
    assert response.status_code == 200
    data = response.get_json()
    assert data['status'] == 'ok'
