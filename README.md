# Data-Cleaning-on-Nashville-House-Data

## Introduction
This repository contains code and data for a data cleaning project that uses MySQL. The goal of this project was to clean a dataset of real estate sales data by performing various data cleaning tasks, including date conversion, string functions, string manipulation, normalization, and removal of duplicates.

## Dataset
The original dataset contained over 56,000 rows of real estate sales data, including information on the property address, sale date, sale price, legal reference, and other attributes.

## Cleaning Tasks
The following data cleaning tasks were performed on the dataset using MySQL:

<b>Date conversion: </b>The sale date column was in a non-standard format, so it was converted to a MySQL date format using the STR_TO_DATE function.

<b>String functions: </b>The legal reference column contained extraneous text that needed to be removed. This was accomplished using the SUBSTRING_INDEX and TRIM functions.

<b>String manipulation: </b>The property address column contained inconsistent capitalization and punctuation, so it was cleaned up using the REPLACE, and TRIM functions.

<b>Normalization: </b>I examined the dataset to determine the relationships between the columns and identify the functional dependencies. For example, we identified that the ParcelID uniquely identified each property, while the combination of ParcelID, PropertyAddress, SaleDate, SalePrice, and LegalReference columns uniquely identified each sale.

<b>Removal of duplicates: </b>In addition to the above, duplicates were removed based on ParcelID, PropertyAddress, SaleDate, SalePrice, and LegalReference columns using a DELETE statement with a subquery.

## Files
The following files are included in this repository:

<b>clean_data.sql: </b>A SQL script that contains the code used to clean the dataset. <br>
<b>original_data.csv: </b>The original dataset in CSV format. <br>
<b>clean_data.csv: </b>The cleaned dataset in CSV format.

## Usage
To run the data cleaning script, open a MySQL command prompt and run the following command <b>"source clean_data.sql;" </b>
This will execute the SQL script and create a new table called clean_data containing the cleaned dataset.
