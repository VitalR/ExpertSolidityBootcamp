// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Owned.sol";

contract GasContract2 is Owned {
    error GasContract2__ZeroAddressProvided();
    error GasContract2__CallerNotAdmin();
    error GasContract2__OnlyAdminOrOwnerAllowed();
    error GasContract2__WhiteListingError1();
    error GasContract2__WhiteListingError2();
    error GasContract2__WhiteListingError3();
    error GasContract2__InsufficientBalance();
    error GasContract2__InvalidName();
    error GasContract2__InvalidIDValue();
    error GasContract2__InvalidAmount();
    error GasContract2__InvalidAddress();
    error GasContract2__LevelMustBeGreater();
    error GasContract2__Emergency();

    uint256 public constant tradeFlag = 1;
    uint256 public constant basicFlag = 0;
    uint256 public constant dividendFlag = 1;

    uint256 public immutable totalSupply; // cannot be updated
    uint256 public paymentCounter;  //= 0

    uint256 public constant tradePercent = 12;
    uint256 public tradeMode; // = 0

    // address public owner;
    // mapping(address admin => bool whitelisted) public administrators;
    address[5] public administrators;
    bool public isReady = false;

    mapping(address => uint256) public balances;
    mapping(address => uint256) public whitelist;

    mapping(address => Payment[]) public payments;

    enum PaymentType {
        Unknown,
        BasicPayment,
        Refund,
        Dividend,
        GroupPayment
    }

    PaymentType constant defaultPayment = PaymentType.Unknown;

    struct Payment {
        PaymentType paymentType;
        uint256 paymentID;
        bool adminUpdated;
        bytes4 recipientName; // max 8 characters
        address recipient;
        address admin; // administrators address
        uint256 amount;
    }

    History[] public paymentHistory; // when a payment was updated

    struct History {
        uint256 lastUpdate;
        address updatedBy;
        uint256 blockNumber;
    }

    uint256 wasLastOdd = 1;
    mapping(address => uint256) public isOddWhitelistUser;

    struct ImportantStruct {
        uint256 amount;
        uint256 bigValue;
        uint16 valueA; // max 3 digits
        uint16 valueB; // max 3 digits
        bool paymentStatus;
        address sender;
    }

    mapping(address => ImportantStruct) public whiteListStruct;

    event AddedToWhitelist(address userAddress, uint256 tier);

    modifier onlyAdminOrOwner() {
        address senderOfTx = msg.sender;
        if (checkForAdmin(senderOfTx)) {
            if (!checkForAdmin(senderOfTx)) {
                revert GasContract2__CallerNotAdmin();
            }
            // require(
            //     checkForAdmin(senderOfTx),
            //     "Gas Contract Only Admin Check-  Caller not admin"
            // );
            _;
        } else if (senderOfTx == owner) {
            _;
        } else {
            revert GasContract2__OnlyAdminOrOwnerAllowed();
            // revert(
            //     "Error in Gas contract - onlyAdminOrOwner modifier : revert happened because the originator of the transaction was not the admin, and furthermore he wasn't the owner of the contract, so he cannot run this function"
            // );
        }
    }

    modifier checkIfWhiteListed(address sender) {
        address senderOfTx = msg.sender;
        if (msg.sender != sender) {
            revert GasContract2__WhiteListingError1();
        }
        // require(
        //     senderOfTx == sender,
        //     "Gas Contract CheckIfWhiteListed modifier : revert happened because the originator of the transaction was not the sender"
        // );
        uint256 usersTier = whitelist[senderOfTx];
        if (usersTier == 0) {
            revert GasContract2__WhiteListingError2();
        }
        // require(
        //     usersTier > 0,
        //     "Gas Contract CheckIfWhiteListed modifier : revert happened because the user is not whitelisted"
        // );
        if (usersTier >= 4) {
            revert GasContract2__WhiteListingError3();
        }
        // require(
        //     usersTier < 4,
        //     "Gas Contract CheckIfWhiteListed modifier : revert happened because the user's tier is incorrect, it cannot be over 4 as the only tier we have are: 1, 2, 3; therfore 4 is an invalid tier for the whitlist of this contract. make sure whitlist tiers were set correctly"
        // );
        _;
    }

    event SupplyChanged(address indexed, uint256 indexed);
    event Transfer(address recipient, uint256 amount);
    event PaymentUpdated(address admin, uint256 ID, uint256 amount, bytes4 recipient);
    event WhiteListTransfer(address indexed);

    constructor(address[] memory _admins, uint256 _totalSupply) Owned(msg.sender) {
        // owner = msg.sender;
        totalSupply = _totalSupply;

        uint256 adminLength = _admins.length;
        for (uint256 ii; ii < adminLength;) {
            if (_admins[ii] != address(0)) {
                // administrators[_admins[ii]] = true;
                administrators[ii] = _admins[ii];
                if (_admins[ii] == owner) {
                    balances[owner] = totalSupply;
                } else {
                    balances[_admins[ii]] = 0;
                }
                if (_admins[ii] == owner) {
                    emit SupplyChanged(_admins[ii], totalSupply);
                } else if (_admins[ii] != owner) {
                    emit SupplyChanged(_admins[ii], 0);
                }
            }
            unchecked {
                ii++;
            }
        }
    }

    function getPaymentHistory() public payable returns (History[] memory paymentHistory_) {
        return paymentHistory;
    }

    function checkForAdmin(address _user) public view returns (bool admin_) {
        bool admin = false;

        uint256 adminLength = administrators.length;
        for (uint256 ii; ii < adminLength;) {
            if (administrators[ii] == _user) {
                admin = true;
            }
            unchecked {
                ii++;
            }
        }
        return admin;
    }

    function balanceOf(address _user) public view returns (uint256 balance_) {
        uint256 balance = balances[_user];
        return balance;
    }

    function getTradingMode() public pure returns (bool mode_) {
        bool mode = false;
        if (tradeFlag == 1 || dividendFlag == 1) {
            mode = true;
        } else {
            mode = false;
        }
        return mode;
    }

    function addHistory(address _updateAddress, bool _tradeMode) public returns (bool status_, bool tradeMode_) {
        History memory history;
        history.blockNumber = block.number;
        history.lastUpdate = block.timestamp;
        history.updatedBy = _updateAddress;
        paymentHistory.push(history);
        bool[] memory status = new bool[](tradePercent);
        for (uint256 i; i < tradePercent;) {
            status[i] = true;
            unchecked {
                i++;
            }
        }
        return ((status[0] == true), _tradeMode);
    }

    function getPayments(address _user) public view returns (Payment[] memory payments_) {
        if (_user == address(0)) {
            revert GasContract2__ZeroAddressProvided();
        }
        // require(
        //     _user != address(0),
        //     "Gas Contract - getPayments function - User must have a valid non zero address"
        // );
        return payments[_user];
    }

    function transfer(address _recipient, uint256 _amount, bytes4 _name) public returns (bool status_) {
        address senderOfTx = msg.sender;
        if (balances[senderOfTx] < _amount) revert GasContract2__InsufficientBalance();
        // require(balances[senderOfTx] >= _amount, "Gas Contract - Transfer function - Sender has insufficient Balance");
        if ((bytes4(_name).length) >= 9) revert GasContract2__InvalidName();
        // require(
        //     bytes(_name).length < 9,
        //     "Gas Contract - Transfer function -  The recipient name is too long, there is a max length of 8 characters"
        // );
        balances[senderOfTx] -= _amount;
        balances[_recipient] += _amount;
        emit Transfer(_recipient, _amount);

        Payment memory payment;
        payment.admin = address(0);
        payment.adminUpdated = false;
        payment.paymentType = PaymentType.BasicPayment;
        payment.recipient = _recipient;
        payment.amount = _amount;
        payment.recipientName = _name;
        unchecked {
            payment.paymentID = ++paymentCounter;    
        }
        payments[senderOfTx].push(payment);
        bool[] memory status = new bool[](tradePercent);

        for (uint256 i; i < tradePercent;) {
            status[i] = true;
            unchecked {
                i++;
            }
        }
        return (status[0] == true);
    }

    function updatePayment(address _user, uint256 _ID, uint256 _amount, PaymentType _type) public onlyAdminOrOwner {
        if (_ID == 0) revert GasContract2__InvalidIDValue();
        // require(_ID > 0, "Gas Contract - Update Payment function - ID must be greater than 0");

        if (_amount == 0) revert GasContract2__InvalidAmount();
        // require(_amount > 0, "Gas Contract - Update Payment function - Amount must be greater than 0");

        if (_user == address(0)) revert GasContract2__InvalidAddress();
        // require(
        //     _user != address(0),
        //     "Gas Contract - Update Payment function - Administrator must have a valid non zero address"
        // );

        // address senderOfTx = msg.sender;

        uint256 paymentsLength = payments[_user].length;
        for (uint256 ii; ii < paymentsLength;) {
            if (payments[_user][ii].paymentID == _ID) {
                payments[_user][ii].adminUpdated = true;
                payments[_user][ii].admin = _user;
                payments[_user][ii].paymentType = _type;
                payments[_user][ii].amount = _amount;
                bool tradingMode = getTradingMode();
                addHistory(_user, tradingMode);
                emit PaymentUpdated(msg.sender, _ID, _amount, payments[_user][ii].recipientName);
            }
            unchecked {
                ii++;
            }
        }
    }

    function addToWhitelist(address _userAddrs, uint256 _tier) external onlyAdminOrOwner {
        if (_tier >= 255) revert GasContract2__LevelMustBeGreater();
        // require(_tier < 255, "Gas Contract - addToWhitelist function -  tier level should not be greater than 255");
        
        whitelist[_userAddrs] = _tier;
        unchecked {
            if (_tier > 3) {
                whitelist[_userAddrs] -= _tier;
                whitelist[_userAddrs] = 3;
            } else if (_tier == 1) {
                whitelist[_userAddrs] -= _tier;
                whitelist[_userAddrs] = 1;
            } else if (_tier > 0 && _tier < 3) {
                whitelist[_userAddrs] -= _tier;
                whitelist[_userAddrs] = 2;
            }
        }
        
        uint256 wasLastAddedOdd = wasLastOdd;
        if (wasLastAddedOdd == 1) {
            wasLastOdd = 0;
            isOddWhitelistUser[_userAddrs] = wasLastAddedOdd;
        } else if (wasLastAddedOdd == 0) {
            wasLastOdd = 1;
            isOddWhitelistUser[_userAddrs] = wasLastAddedOdd;
        } else {
            revert GasContract2__Emergency(); // ("Contract hacked, imposible, call help");
        }
        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(address _recipient, uint256 _amount) public checkIfWhiteListed(msg.sender) {
        // address senderOfTx = msg.sender;
        whiteListStruct[msg.sender] = ImportantStruct(_amount, 0, 0, 0, true, msg.sender);

        if (balances[msg.sender] < _amount) revert GasContract2__InsufficientBalance();
        // require(
        //     balances[senderOfTx] >= _amount, "Gas Contract - whiteTransfers function - Sender has insufficient Balance"
        // );
        
        if (_amount <= 3) revert GasContract2__InvalidAmount();
        // require(_amount > 3, "Gas Contract - whiteTransfers function - amount to send have to be bigger than 3");

        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        balances[msg.sender] += whitelist[msg.sender];
        balances[_recipient] -= whitelist[msg.sender];

        emit WhiteListTransfer(_recipient);
    }

    function getPaymentStatus(address sender) public view returns (bool, uint256) {
        return (whiteListStruct[sender].paymentStatus, whiteListStruct[sender].amount);
    }

    receive() external payable {
        payable(msg.sender).transfer(msg.value);
    }

    // fallback() external payable {
    //     payable(msg.sender).transfer(msg.value);
    // }
}
