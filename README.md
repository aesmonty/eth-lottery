# eth-lottery
Differents variants of a lottery in Ethereum

This project consists on the development of fair lottery frameworks in Ethereum. 

## Report
The report includes the rationale, mathematical deduction and description of the variants on the lottery designs.

## Versions
Each of the four versions focus in different aspects of the lottery (eg. security, performance or gas fairness).

* **lottery1.sol -** Standard lottery version with security optimizations.
* **lottery2.sol -** Gas optimizations.
* **lottery3.sol -** Gas fairness optimization for the lottery participants (not the deployer/owner of the contract).
* **lottery4.sol -** Gas fairness optimization with lottery owner incentives compatibility.
