import json
from influxdb_client import InfluxDBClient, Point
from influxdb_client.client.write_api import SYNCHRONOUS
import sys

def main():

    # The address of the InfluxDB server
    host = "localhost"

    # The port of the InfluxDB server
    port = 8086

    # The database name
    database = "GeniusVentures"

    # The bucket name
    my_bucket = "WalletInfo"

    # Get the balance and address from the command line arguments
    my_token = sys.argv[1]
    balance = float(sys.argv[2])
    address = sys.argv[3]

    # Create a JSON object for the data point
    my_data = {
        "measurement": "walletBalance",
        "tags": {
            "address": address
        },
        "fields": {
            "balance": balance
        }
    }

    # Create an InfluxDB client
    client = InfluxDBClient(url="http://localhost:8086", token=my_token, org=database)

    write_api = client.write_api(write_options=SYNCHRONOUS)
    query_api = client.query_api()

    tables = query_api.query(f'from(bucket:"{my_bucket}") |> range(start: -12h) |> filter(fn: (r) => r._measurement == "walletBalance" and r.address == "{address}")')

    # If the data point does not exist, create it
    if not tables:
        write_api.write(bucket=my_bucket, record=my_data)
    # Otherwise, update the balance of the data point
    else:
        ##data_point = tables[0]
        #data_point["fields"]["balance"] = balance
        #write_api.write(bucket=my_bucket, record=data_point)
        write_api.write(bucket=my_bucket, record=my_data)

if __name__ == "__main__":

    # Call the main function
    main()
