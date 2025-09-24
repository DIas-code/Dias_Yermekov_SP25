import os
import sys
import yaml
from selenium import webdriver
from webdriver_manager.chrome import ChromeDriverManager
import pytest
from Pages.incomeStatementsReportPage import IncomeStatementsReportPage


def get_selenium_config(config_name):
    module_dir = os.path.dirname(os.path.abspath(sys.modules[__name__].__file__))
    parent_dir = os.path.dirname(module_dir)
    with open(os.path.join(parent_dir, 'Configs', config_name), 'r') as stream:
        config = yaml.safe_load(stream)
    return config['global']


@pytest.fixture(scope="function")
def open_income_statements_report_webpage():
    report_uri = get_selenium_config('config_selenium.yaml')['report_uri']
    delay = get_selenium_config('config_selenium.yaml')['delay']
    driver = webdriver.Chrome(ChromeDriverManager().install())
    driver.set_window_size(1024, 600)
    driver.maximize_window()
    driver.get(report_uri)

    income_report = IncomeStatementsReportPage(driver, delay)
    income_report.open_power_bi_report()
    yield income_report
    driver.close()


def test_01_open_decomposition_tree_visualization(open_income_statements_report_webpage):
    report_page = open_income_statements_report_webpage
    report_page.switch_to_report_frame()
    report_title = report_page.get_revenue_report_title()
    assert report_title == 'REVENUE (in billions)'
