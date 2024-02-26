//SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.0;

contract CustomError {
    error ONLY_OWNER_CAN_UPDATE_LISTING_PRICE();
    error SEND_THE_CORRECT_PRICE();
    error PRICE_IS_NOT_VALID();
}
