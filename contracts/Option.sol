pragma solidity ^0.4.10;

import '../installed_contracts/zeppelin/contracts/token/ERC20.sol';

contract Option {

	event OptionEvent(OptionType indexed _optionType, address indexed _issuer, address indexed _counterparty, State _state, uint256 _price, uint256 _expiry, uint256 _notional, uint256 _strike);

	enum State { Pending, Live, Active, Exercised, Closed }

  enum OptionType { Call, Put }

	State public state;
  OptionType public optionType;
	ERC20 public token;
	address public issuer;
	address public counterparty;
	uint256 public price;
	uint256 public expiry;
	uint256 public notional;
	uint256 public strike;

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

	function Option(OptionType _optionType, address _tokenAddress, uint256 _price, uint256 _expiry, uint256 _notional, uint256 _strike) {
		token = ERC20(_tokenAddress);
    optionType = _optionType;
		issuer = msg.sender;
		price = _price;
		expiry = _expiry;
		notional = _notional;
		strike = _strike;
		state = State.Pending;
    OptionEvent(optionType, issuer, counterparty, state, price, expiry, notional, strike);
	}

	function destroy() internal onlyWhen(State.Closed) {
		selfdestruct(issuer);
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
		OptionEvent(optionType, issuer, counterparty, state, price, expiry, notional, strike);
	}

  function collateralizeOption() payable onlyWhen(State.Pending);

	function exerciseOption() payable onlyWhen(State.Active);

	function closeOption() notWhen(State.Active);

}
