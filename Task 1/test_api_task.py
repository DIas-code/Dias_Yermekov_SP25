def test_user_with_posts(provide_posts_data):
    posts = provide_posts_data
    assert len(posts) == 10, f"Expected 10 posts, but got {len(posts)}"


def test_data_is_presented_between_staging_raw(list_gcs_blobs, list_aws_blobs):
    aws = list_aws_blobs
    gcs = list_gcs_blobs
    assert aws == gcs
