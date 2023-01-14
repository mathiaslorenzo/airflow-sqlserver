FROM apache/airflow:latest as builder

# Log as root
USER root

# Essentials for connection
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list


RUN apt-get update
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17
RUN ACCEPT_EULA=Y apt-get install -y mssql-tools
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

# next stage
FROM apache/airflow:latest as airflow

# Log as root
USER root

# install required packages for pyodbc
RUN apt-get install -y unixodbc

# # install updated and required pip packages
RUN python -m pip install pyodbc
RUN python -m pip install apache-airflow-providers-odbc 
RUN python -m pip install apache-airflow-providers-microsoft-azure 
RUN python -m pip install loguru   
RUN python -m pip install bson
RUN python -m pip install requests

#change openssl settings for sql server connection to work
RUN sed -i 's/TLSv1.2/TLSv1.0/g' /etc/ssl/openssl.cnf
RUN sed -i 's/SECLEVEL=2/SECLEVEL=1/g' /etc/ssl/openssl.cnf 
