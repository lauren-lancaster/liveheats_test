# Liveheats Tech Test

## Description

This web-based system is designed to help teachers at a local school manage race day results for students. It allows teachers to set up races, assign students to lanes, record their finishing places, and view the results.

I have made a conscious choice not to include tests in my SETUP, README, and Migration commits. The rest of this app is TDD

## Features Implemented

**Race Setup**:
* Teachers can create new races.
* Teachers can assign students to specific lanes for each race.
* A race requires at least 2 students to be set up.
* The app prevents assigning the same student to multiple lanes in the same race.
* The app prevents assigning different students to the same lane in the same race.
  
**Result Recording**:
* Teachers can enter the final finishing place for each student in a race.
* The app validates that places are entered without gaps (e.g., 1, 2, 3 is valid; 1, 3 is not if only two participants).
* The app correctly handles ties in placings (e.g., if two students tie for 1st, the next place is 3rd).
  
**Result Viewing**:
* Teachers can view a list of all races and results.

## User Guide

1. Register students
2. Set up a race. Assign students to lanes (1 student per lane, minimum 2 students)
3. Record results. Enter the place of each student
4. View results

5. Any stage of the race creation process can be accessed from 'Manage Races'. From there students can be assigned to a race, results can be recorded, or a completed race can be viewed

## Tech Stack

* Ruby 3.2.4
* Rails 7.1.5.1
* Database: SQLite3
* Testing Framework: Unit tests with Rspec

## Prerequisites

Before you begin, ensure you have the following installed:
* ruby 3.2.4
* nodejs 20.15.0
* yarn 1.22.10
* Bundler (`gem install bundler`)
* SQLite3

## Setup and Installation

1.  **Clone the Repository:**

    Clone the project repository to your local machine
    ```
    git clone git@github.com:lauren-lancaster/liveheats_test.git
    ```
3.  **Navigate to the Project Directory:**

    Change into the newly cloned project directory:

    ```
    cd liveheats_test
    ```
5.  **Install Ruby Dependencies:**

    This project uses Bundler to manage Ruby gems. Install the required gems by running:

    ```
    bundle install
    ```
7.  **Install JavaScript Dependencies:**

    This project uses Yarn to manage JavaScript packages. Install them by running:

    ```
    yarn install
    ```
9.  **Database Setup (SQLite3):**

    This application uses SQLite3

    * **Create the database:** 
        ```
        rails db:create
        ```

    * **Run database migrations:** 
        ```
        rails db:migrate
        ```

## Running the Application

To run the application:
`bin/rails server`

## Running the Tests

To run the test suite:
`bundle exec rspec`

## DB Diagram

<img width="995" alt="Screenshot 2025-06-05 at 2 30 38 PM" src="https://github.com/user-attachments/assets/30fb6b01-84e7-4787-af7b-2fb6d5be9f6e" />

