# Aderyn Analysis Report


## Files Summary

| Key | Value |
| --- | --- |
| .sol Files | 3 |
| Total nSLOC | 87 |


## Files Details

| Filepath | nSLOC |
| --- | --- |
| src/SantaToken.sol | 22 |
| src/SantasList.sol | 60 |
| src/TokenUri.sol | 5 |
| **Total** | **87** |


## Issue Summary

| Category | No. of Issues |
| --- | --- |
| Critical | 0 |
| High | 0 |
| Medium | 0 |
| Low | 0 |
| NC | 3 |


# NC Issues

## NC-1: Functions not used internally could be marked external



- Found in src/SantasList.sol [Line: 144](src/SantasList.sol#L144)

	```solidity
	    function tokenURI(uint256 /* tokenId */ ) public pure override returns (string memory) {
	```



## NC-2: Constants should be defined and used instead of literals



- Found in src/SantaToken.sol [Line: 25](src/SantaToken.sol#L25)

	```solidity
	        _mint(to, 1e18);
	```

- Found in src/SantaToken.sol [Line: 32](src/SantaToken.sol#L32)

	```solidity
	        _burn(from, 1e18);
	```



## NC-3: Event is missing `indexed` fields

Index event fields make the field more quickly accessible to off-chain tools that parse events. However, note that each index field costs extra gas during emission, so it's not necessarily best to index the maximum allowed per event (three fields). Each event should use three indexed fields if there are three or more fields, and gas usage is not particularly of concern for the events in question. If there are fewer than three fields, all of the fields should be indexed.

- Found in src/SantasList.sol [Line: 48](src/SantasList.sol#L48)

	```solidity
	    event CheckedOnce(address person, Status status);
	```

- Found in src/SantasList.sol [Line: 49](src/SantasList.sol#L49)

	```solidity
	    event CheckedTwice(address person, Status status);
	```



