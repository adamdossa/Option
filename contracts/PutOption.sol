pragma solidity ^0.4.10;

import '../installed_contracts/zeppelin/contracts/token/ERC20.sol';
import './Option.sol';

contract PutOption is Option {

	function collateralizeOption() payable onlyIssuer {
    state = State.Live;
    if (msg.value != strike * notional) {
			throw;
		}
		OptionEvent(optionType, issuer, counterparty, state, price, expiry, notional, strike);
	}

	function exerciseOption() payable onlyCounterparty {
    state = State.Exercised;
    if (msg.value != 0) {
			throw;
		}
    if (block.number > expiry) {
			throw;
		}
    token.transferFrom(counterparty, this, notional);
    if (!msg.sender.send(this.balance)) {
      throw;
    }
		OptionEvent(optionType, issuer, counterparty, state, price, expiry, notional, strike);
	}

	function closeOption() onlyIssuer {

    state = State.Closed;

		if (state == State.Exercised) {
			token.transfer(issuer, notional);
		}

		if (state == State.Live) {
			if (!msg.sender.send(this.balance)) {
				throw;
			}
		}

		OptionEvent(optionType, issuer, counterparty, state, price, expiry, notional, strike);

		destroy();

	}

}
