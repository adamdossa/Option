pragma solidity ^0.4.10;

import '../installed_contracts/zeppelin/contracts/token/ERC20.sol';

contract CallOption {

	event CallOptionEvent(address indexed _issuer, address indexed _counterparty, State _state, uint256 _price, uint256 _expiry, uint256 _notional, uint256 _strike);

	enum State { Pending, Live, Active, Exercised, Closed }

	State state;
	ERC20 token;
	address issuer;
	address counterparty;
	uint256 price;
	uint256 expiry;
	uint256 notional;
	uint256 strike;

	modifier onlyWhen(State _state) {
		if (state != _state) {
			throw;
		}
		_;
	}

	modifier notWhen(State _state) {
		if (state == _state) {
			throw;
		}
		_;
	}

	modifier onlyCounterparty() {
		if (msg.sender != counterparty) {
			throw;
		}
		_;
	}

	modifier onlyIssuer() {
		if (msg.sender != issuer) {
			throw;
		}
		_;
	}

	function CallOption(address _tokenAddress, uint256 _price, uint256 _expiry, uint256 _notional, uint256 _strike) {
		token = ERC20(_tokenAddress);
		issuer = msg.sender;
		price = _price;
		expiry = _expiry;
		notional = _notional;
		strike = _strike;
		state = State.Pending;
		CallOptionEvent(issuer, counterparty, state, price, expiry, notional, strike);
	}

	function collateralizeOption() onlyIssuer {
		token.transferFrom(issuer, this, notional);
		state = State.Live;
		CallOptionEvent(issuer, counterparty, state, price, expiry, notional, strike);
	}

	function buyOption() payable onlyWhen(State.Live) {
		if (msg.value != price) {
			//Wrong price being paid
			throw;
		}
		if (block.number > (expiry - 1)) {
			throw;
		}
		counterparty = msg.sender;
		state = State.Active;
		CallOptionEvent(issuer, counterparty, state, price, expiry, notional, strike);
	}

	function exerciseOption() payable onlyWhen(State.Active) onlyCounterparty {
		if (msg.value != strike * notional) {
			throw;
		}
		if (block.number > expiry) {
			throw;
		}
		token.transfer(counterparty, notional);
		state = State.Exercised;
		CallOptionEvent(issuer, counterparty, state, price, expiry, notional, strike);
	}

	function closeOption() notWhen(State.Active) onlyIssuer {

		if (state == State.Live) {
			token.transfer(issuer, notional);
		}

		if (state == State.Exercised) {
			if (!msg.sender.send(this.balance)) {
				throw;
			}
		}

		state = State.Closed;

		CallOptionEvent(issuer, counterparty, state, price, expiry, notional, strike);

		destroy();

	}

	function destroy() internal {
		selfdestruct(issuer);
	}

}
