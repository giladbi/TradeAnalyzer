# Trade Analyzer (TA)

## Overview
The purpose of this project is to develop a proof-of-concept (PoC) data product in R that can be used to quickly backtest a variety of stock swing trading strategies that require holding a position for multiple days.  Unlike Day Trading (DT) which is practiced by entering and exiting multiple position in a single day, Swing Trading (ST) typically involves holding positions for days, weeks, or sometimes longer.  Because interday quote data is not manditory to practice ST, the use of freely available daily quote data from sources such as **finance.yahoo** can be used.

Each strategy to be evaluated by the TA requires writing three components.  The first component is a **signal generator**.  The second component is the **action generator** which takes the signals from the signal generator and creates recommended actions such as: *buy*, *sell*, or *hold*.  The third component is the **simulator** which takes the actions from the action generator, a position sizing strategy, and an initial account balance as input and outputs positions and account balances on each day of the data set.

A short 5 slide presentation of the project can be found [here](http://example.com)

## Architecture
The TA is architected to be modular in that to implement a new strategy, you only need to write a new stratgey which conforms to the interface.

### Writing a New Strategy
TBD

## Revision History
#### Rev 1 - 12/27/2015
Initial release. First implemented strategy: classic **simple moving average** (SMA) cross-over strategy: only long positions permitted, long positions must be closed before opening new position, default price = closing
#### Rev 2 - mm/dd/2016
TDB

## Roadmap & Proposed Future Work
#### TBD  
#### TBD

## Crazy Ideas...
#### Neural Net Classification-based strategies
#### Port to OpenCPU
#### Port to Java as REST service on backend and AngularJS-based client