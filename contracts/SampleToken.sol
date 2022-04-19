//SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor() ERC20("Token", "TK") {
        _mint(msg.sender, 10**24);
    }
}
