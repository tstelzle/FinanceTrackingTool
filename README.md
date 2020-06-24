# Update

There is the solution from GnuCash (https://www.gnucash.org/), which offers the possibility to synchronize the database file with a cloud solution. 
This works really good between workstations. 
On mobile the synchronization process needs an update, which is already on high príority. 

Therefore I would change the topic of this repository to making an implementation of an app which can parse receipts.
There should be different output formats from this app. 
With one of these you should be able to import the transaction to your GnuCash instance.

# Finance Tracking Tool FTT

The idea of this project is to build a simple tool to help you with your finances.
The tool should get a picture of a receipt, later from an app, and then read the contents on it. 
The date, the store, the article and the price on the receipt should then be stored in a database. 
Further information like a category should also be added to the database entry.
If the article is not known yet, there should be a request to add the additional information. 

## Features App

Later on there should be an app from which the photos of a receipt can be send to the server. 
The app should also be able to list results from a query on the database.

* make pictures
* get basic data from database

## Features Website

In a next step there should be a web tool, which should have the same, if not more, features as the app.
Additional features could be plotting graphs of the database entries.

* plotting graphs
* get data from database
* link to products as same, which have a different name
* ...

### Techstack Server

* python: Read picture
* python: analyze picture
* python: send db commands
* db: first - squlite, then - ?

## Techsteck App and Website

* app:
* website:

## Suggestions and Issues

You can always open a new issue, if you have
* a feature idea,
* improvments for the app concept,
* anything else. 

In this way, it is possible to discuss your point with other developers of this tool.

## TODOs

* How will the data be safely transferred from the app/website to and from the server?
