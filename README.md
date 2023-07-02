## Companies API for evaluation. 

A super simple service to convert xml from a downstream service into json.

Implemented in Dart as a comparison to [CompaniesApi ASP.Net Implementation](https://github.com/paulfaid/MWNZ)

## Dependancies

 - Dart 3.0
 
## Getting started

After cloning the repo

To execute the tests:
`dart run test/companies_api_test.dart`

To run the server:
`dart run bin/companies_api.dart`

## Things worth considering.

Tests
 - The included tests are some minimal integration tests. These should really use a mocked backend service. 
 - Adding some unit tests would require spreading the handler implementaion across some small testable functions.


    
    




