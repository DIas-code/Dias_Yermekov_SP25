import psycopg2
import pytest
import os
import yaml

@pytest.fixture(scope="session")
def dwh_conn():
    conn = psycopg2.connect(
        database="dwh_hw_db",
        user='postgres',
        password='iLove3822',
        host='localhost',
        port='5432'
    )
    yield conn
    conn.close()

@pytest.fixture(scope="function")
def dwh_cur(dwh_conn):
    cur = dwh_conn.cursor()
    yield cur
    cur.close()

@pytest.fixture(scope="session")
def sql_tests():
    conf_path = os.path.join(os.path.dirname(__file__), "config_SQL_example.yaml")
    with open(conf_path, "r") as f:
        tests = yaml.safe_load(f)
    return tests["tests"]