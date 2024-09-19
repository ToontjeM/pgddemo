select node_name CONNECTED_TO from bdr.local_node_summary;
select count(*) from ping;
INSERT INTO ping(node, timestamp) select node_name, current_timestamp from bdr.local_node_summary;
