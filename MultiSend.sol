// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultiSend {
    event Sent(address indexed to, uint256 amount);

    function multiSend(address[] calldata recipients) public payable {
        require(recipients.length > 0, "No recipients");
        require(msg.value > 0, "Send some Ether");

        uint256 share = msg.value / recipients.length;
        require(share > 0, "Amount too small to split");

        for (uint256 i = 0; i < recipients.length; i++) {
            (bool success, ) = payable(recipients[i]).call{value: share}("");
            require(success, "Transfer failed");
            emit Sent(recipients[i], share);
        }

        uint256 remainder = msg.value - (share * recipients.length);
        if (remainder > 0) {
            (bool refunded, ) = payable(msg.sender).call{value: remainder}("");
            require(refunded, "Refund failed");
        }
    }
}