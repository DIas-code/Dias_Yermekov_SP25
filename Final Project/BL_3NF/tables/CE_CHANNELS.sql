-- bl_3nf.ce_channels channel where order was done
CREATE SEQUENCE IF NOT EXISTS BL_3NF.SEQ_CE_CHANNELS START WITH 1;

CREATE TABLE IF NOT EXISTS bl_3nf.ce_channels (
	channel_id BIGINT PRIMARY KEY,
	channel_src_id varchar(255) NOT NULL,
	channel_name varchar(64) NOT NULL,
	channel_desc varchar(255) NOT NULL,
	source_system varchar(255) NOT NULL,
	source_entity varchar(255) NOT NULL,
	ta_insert_dt date NOT NULL,
	ta_update_dt date NOT NULL
);