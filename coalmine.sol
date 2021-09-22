pragma solidity ^0.4.2;

import "./ownable.sol";
import "./safemath.sol";
import "./oraclizeAPI.sol";

contract CoalMine is 
	Ownable,  
	usingOraclize{
    
    uint coalFee = 0.000001 ether;
    uint diceFee = 0.000001 ether;
    uint diamondSecurity;
    uint diamondLocked;
	
	event NewDiamond(
		uint256 diamondId, 
		uint256 diamondComposition, 
		uint64 diamondColor, 
		uint256 diamondOrigin, 
		uint256 diamondCarats, 
		uint256 diamondQuality, 
		uint256 diamondClarity, 
		uint256 diamondShape
	);

	struct Diamond{
	    uint256 diamondComposition;
	    uint64 diamondColor;
	    uint64 diamondCarats;
	    uint16 diamondOrigin;
	    uint16 diamondQuality;
	    uint16 diamondClarity;
	    uint16 diamondShape;
	}
	
	Diamond[] public diamonds;
	
	mapping(uint => address) private diamondToOwner;
	mapping(address => uint) private ownerDice;
	mapping(address => uint) private ownerDiamondCount;
	mapping(uint => address) private diamondApprovals;
	
	modifier onlyOwnerOf(uint _diamondId) {
        require(msg.sender == diamondToOwner[_diamondId]);
        _;
    }
    
    modifier needsDice() {
	    require(ownerDice[msg.sender] >= 1);
	    require(diamondLocked >= 1);
	    _;
	}
	
	modifier scrambleOwnerSecond(
		uint _firstDiamond, 
		uint _secondDiamond
		) {
			require(
				msg.sender == diamondToOwner[_firstDiamond] && 
				msg.sender == diamondToOwner[_secondDiamond] && 
				_firstDiamond != _secondDiamond && 
				_firstDiamond >= 1 && 
				_secondDiamond >= 1
			);
			_;
		}
		
    modifier scrambleOwnerThird(
		uint _firstDiamond, 
		uint _secondDiamond, 
		uint _thirdDiamond
		) {
			require(
				msg.sender == diamondToOwner[_firstDiamond] && 
				msg.sender == diamondToOwner[_secondDiamond] && 
				msg.sender == diamondToOwner[_thirdDiamond] && 
				_firstDiamond != _secondDiamond && 
				_firstDiamond != _thirdDiamond && 
				_secondDiamond != _thirdDiamond && 
				_firstDiamond >= 1 && 
				_secondDiamond >= 1 && 
				_thirdDiamond >= 1
			);
			_;
		}
		
    modifier scrambleOwnerFourth(
		uint _firstDiamond, 
		uint _secondDiamond, 
		uint _thirdDiamond, 
		uint _fourthDiamond
		) {
			require(
				msg.sender == diamondToOwner[_firstDiamond] && 
				msg.sender == diamondToOwner[_secondDiamond] && 
				msg.sender == diamondToOwner[_thirdDiamond] && 
				msg.sender == diamondToOwner[_fourthDiamond] && 
				_firstDiamond != _secondDiamond && 
				_firstDiamond != _thirdDiamond && 
				_firstDiamond != _fourthDiamond && 
				_secondDiamond != _thirdDiamond && 
				_secondDiamond != _fourthDiamond && 
				_fourthDiamond != _thirdDiamond && 
				_fourthDiamond != _secondDiamond && 
				_firstDiamond >= 1 && 
				_secondDiamond >= 1 && 
				_thirdDiamond >= 1 && 
				_fourthDiamond >= 1
			);
			_;
		}
		
    modifier scrambleOwnerFifth(
		uint _firstDiamond, 
		uint _secondDiamond, 
		uint _thirdDiamond, 
		uint _fourthDiamond, 
		uint _fifthDiamond
		) {
			require(
				msg.sender == diamondToOwner[_firstDiamond] && 
				msg.sender == diamondToOwner[_secondDiamond] && 
				msg.sender == diamondToOwner[_thirdDiamond] && 
				msg.sender == diamondToOwner[_fourthDiamond] && 
				msg.sender == diamondToOwner[_fifthDiamond] && 
				_firstDiamond != _secondDiamond && 
				_firstDiamond != _thirdDiamond && 
				_firstDiamond != _fourthDiamond && 
				_firstDiamond != _fifthDiamond && 
				_secondDiamond != _thirdDiamond && 
				_secondDiamond != _fourthDiamond && 
				_secondDiamond != _fifthDiamond && 
				_fourthDiamond != _fifthDiamond && 
				_fourthDiamond != _thirdDiamond && 
				_fourthDiamond != _secondDiamond && 
				_fifthDiamond != _thirdDiamond && 
				_firstDiamond >= 1 && 
				_secondDiamond >= 1 && 
				_thirdDiamond >= 1 && 
				_fourthDiamond >= 1 && 
				_fifthDiamond >= 1
			);
			_;
		}
	
    function balanceOf(address _owner) public view returns (uint256) {
        return uint256(ownerDiamondCount[_owner]);
    }
        
    function viewLock() public view returns (uint256) {
     return diamondLocked;
    }
    
    function viewDice() public view returns (uint256) {
		uint256 currentDice = ownerDice[msg.sender];
		return currentDice;
    }
  
    function viewSecurity() public view returns (uint256) {
        return diamondSecurity;
    }  
    
    function ownerOf(uint256 _diamondId) public view returns (address _owner) {
		return diamondToOwner[_diamondId];
	}
    
    function _transfer(
		address _from, 
		address _to, 
		uint256 _diamondId
		) 
		private {
			ownerDiamondCount[_to] = ownerDiamondCount[_to]++;
			ownerDiamondCount[msg.sender] = ownerDiamondCount[msg.sender]--;
			diamondToOwner[_diamondId] = _to;
			emit Transfer(
				_from, 
				_to, 
				_diamondId
			);
		}
    
    function transfer(
		address _to, 
		uint256 _diamondId
			) public onlyOwnerOf(_diamondId) {
				_transfer(
					msg.sender, 
					_to, 
					_diamondId
				);
			}
    
    function approve(
		address _to, 
		uint256 _diamondId
		) public onlyOwnerOf(_diamondId) {
			diamondApprovals[_diamondId] = _to;
			emit Approval(
				msg.sender, 
				_to, 
				_diamondId
			);
		}
    
    function takeOwnership(uint256 _diamondId) public {
        require(
			diamondApprovals[_diamondId] == msg.sender
		);
        address owner = ownerOf(_diamondId);
        _transfer(
			owner, 
			msg.sender, 
			_diamondId
		);
    }

	function lockMechanism() external onlyOwner {
	    assert(
			diamondLocked == 0
		);
		diamondLocked = now;
		diamondSecurity = uint64(
			oraclize_query (
				"WolframAlpha", 
				"random number between 0 and 9223372036854775807"
			)
		);
	}
	
	function isItLocked() public view returns (uint) {
	    return diamondLocked;
	}
	
	function toBytes(address a) private pure returns (bytes32 b){
		assembly {
			let m := mload(0x40)
			mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, a))
			mstore(0x40, add(m, 52))
			b := m
		}
    }
	
	function withdraw() external onlyOwner {
	    owner.transfer(this.balance);
	}
	
    function diamondScramble(
		uint256 _firstDiamond, 
		uint _secondDiamond, 
		uint256 _thirdDiamond, 
		uint256 _fourthDiamond, 
		uint256 _fifthDiamond
	) external payable needsDice  {
	    _diamondScramble(
			msg.sender, 
			_firstDiamond, 
			_secondDiamond, 
			_thirdDiamond, 
			_fourthDiamond, 
			_fifthDiamond
		);
	}
	
	function _diamondScramble(
		address _from, 
		uint256 _firstDiamond, 
		uint256 _secondDiamond, 
		uint256 _thirdDiamond, 
		uint256 _fourthDiamond, 
		uint256 _fifthDiamond
			) private {
				uint _scrambleType;
				address _dAdd = _from;
				if (
					_scrambleType == 0 && 
					_firstDiamond > 0 && 
					_secondDiamond > 0 && 
					_thirdDiamond > 0 && 
					_fourthDiamond > 0 && 
					_fifthDiamond > 0
				) {
					_scrambleType = 1;
					_fifthScramble(
						_dAdd, 
						_firstDiamond, 
						_secondDiamond, 
						_thirdDiamond, 
						_fourthDiamond, 
						_fifthDiamond
					);
				}
				else {
					if (
					_scrambleType == 0 && 
					_firstDiamond > 0 && 
					_secondDiamond > 0 && 
					_thirdDiamond > 0 && 
					_fourthDiamond > 0
					) 
					{
						_scrambleType = 1;
						_fourthScramble(
							_dAdd, 
							_firstDiamond, 
							_secondDiamond, 
							_thirdDiamond, 
							_fourthDiamond
						);
					}
					else {
						if (
							_scrambleType == 0 && 
							_firstDiamond > 0 && 
							_secondDiamond > 0 && 
							_thirdDiamond > 0
						) {
							_scrambleType = 1;
							_thirdScramble(
								_dAdd, 
								_firstDiamond, 
								_secondDiamond, 
								_thirdDiamond
							);
						}
						else {
							if (
								_scrambleType == 0 && 
								_firstDiamond > 0 && 
								_secondDiamond > 0
							) {
								_scrambleType = 1;
								_secondScramble(
									_dAdd, 
									_firstDiamond, 
									_secondDiamond
								);
							}
							else {
							}
						}
					}
				}
			}
	
	function _fifthScramble(
		address _dAdd, 
		uint256 _firstDiamond, 
		uint256 _secondDiamond, 
		uint256 _thirdDiamond, 
		uint256 _fourthDiamond, 
		uint256 _fifthDiamond
		) private scrambleOwnerFifth(
			_firstDiamond, 
			_secondDiamond, 
			_thirdDiamond, 
			_fourthDiamond, 
			_fifthDiamond
			) {
				ownerDiamondCount[msg.sender] = ownerDiamondCount[msg.sender] - 5;
				diamondToOwner[_firstDiamond] = address(this);
				diamondToOwner[_secondDiamond] = address(this);
				diamondToOwner[_thirdDiamond] = address(this);
				diamondToOwner[_fourthDiamond] = address(this);
				diamondToOwner[_fifthDiamond] = address(this);
				emit Transfer(
					_dAdd, 
					this, 
					_firstDiamond
				);
				emit Transfer(
					_dAdd, 
					this, 
					_secondDiamond
				);
				emit Transfer(
					_dAdd, 
					this, 
					_thirdDiamond
				);
				emit Transfer(
					_dAdd, 
					this, 
					_fourthDiamond
				);
				emit Transfer(
					_dAdd, 
					this, 
					_fifthDiamond
				);
				ownerDice[msg.sender] = uint256(
					ownerDice[msg.sender] - 1
				);
				uint fifthPush = uint256(
					ownerDice[msg.sender]
				);
				uint fifthRandomDiamondComposition = _generateDiamondComposition(fifthPush);
				fifthRandomDiamondComposition = fifthRandomDiamondComposition + uint256(keccak256(now));
				_createScramble(fifthRandomDiamondComposition);
				ownerDice[msg.sender]++;
			}
    
    function _fourthScramble(
		address _dAdd, 
		uint256 _firstDiamond, 
		uint256 _secondDiamond, 
		uint256 _thirdDiamond, 
		uint256 _fourthDiamond
		) private scrambleOwnerFourth(
			_firstDiamond, 
			_secondDiamond, 
			_thirdDiamond, 
			_fourthDiamond
			) {
				ownerDiamondCount[msg.sender] = ownerDiamondCount[msg.sender] - 4;
				diamondToOwner[_firstDiamond] = address(this);
				diamondToOwner[_secondDiamond] = address(this);
				diamondToOwner[_thirdDiamond] = address(this);
				diamondToOwner[_fourthDiamond] = address(this);
				emit Transfer(
					_dAdd, 
					this, 
					_firstDiamond
				);
				emit Transfer(
					_dAdd, 
					this, 
					_secondDiamond
				);
				emit Transfer(
					_dAdd, 
					this, 
					_thirdDiamond
				);
				emit Transfer(
					_dAdd, 
					this, 
					_fourthDiamond
				);
				ownerDice[msg.sender] = uint256(
					ownerDice[msg.sender] - 1
				);
				uint fourthCompositionPush = uint256(
					ownerDice[msg.sender]
				);
				uint fourthRandomDiamondComposition = _generateDiamondComposition(fourthCompositionPush);
				fourthRandomDiamondComposition = fourthRandomDiamondComposition + uint256(keccak256(now));
				_createScramble(fourthRandomDiamondComposition);
				ownerDice[msg.sender]++;
			}
    
    function _thirdScramble(
		address _dAdd, 
		uint256 _firstDiamond, 
		uint256 _secondDiamond, 
		uint256 _thirdDiamond
		) private scrambleOwnerThird(
			_firstDiamond, 
			_secondDiamond, 
			_thirdDiamond
		) {
			ownerDiamondCount[msg.sender] = ownerDiamondCount[msg.sender] - 3;
			diamondToOwner[_firstDiamond] = address(this);
			diamondToOwner[_secondDiamond] = address(this);
			diamondToOwner[_thirdDiamond] = address(this);
			emit Transfer(
				_dAdd, 
				this, 
				_firstDiamond
			);
			emit Transfer(
				_dAdd, 
				this, 
				_secondDiamond
			);
			emit Transfer(
				_dAdd, 
				this, 
				_thirdDiamond
			);					
			ownerDice[msg.sender] = uint256(
				ownerDice[msg.sender] - 1
			);
			uint thirdCompositionPush = uint256(
				ownerDice[msg.sender]
			);
			uint thirdRandomDiamondComposition = _generateDiamondComposition(thirdCompositionPush);
			thirdRandomDiamondComposition = thirdRandomDiamondComposition + uint256(keccak256(now));
			_createScramble(thirdRandomDiamondComposition);
			ownerDice[msg.sender]++;
		}
    
    function _secondScramble(
		address _dAdd, 
		uint256 _firstDiamond, 
		uint256 _secondDiamond
		) private scrambleOwnerSecond(
			_firstDiamond, 
			_secondDiamond
		) {
			ownerDiamondCount[msg.sender] = ownerDiamondCount[msg.sender] - 2;
			diamondToOwner[_firstDiamond] = address(this);
			diamondToOwner[_secondDiamond] = address(this);
			emit Transfer(
				_dAdd, 
				this, 
				_firstDiamond
			);
			emit Transfer(
				_dAdd, 
				this, 
				_secondDiamond
			);
			ownerDice[msg.sender] = uint256(
				ownerDice[msg.sender] - 1
			);
			uint secondCompositionPush = uint256(
				ownerDice[msg.sender]
			);
			uint secondRandomDiamondComposition = _generateDiamondComposition(secondCompositionPush);
			secondRandomDiamondComposition = secondRandomDiamondComposition + uint256(keccak256(now));
			_createScramble(secondRandomDiamondComposition);
			ownerDice[msg.sender]++;
		}
	
	function _createScramble(uint256 _diamondComposition) private {
		uint _diamondColor = uint64(
			(
				_diamondComposition % 500000
			) + 500000
		);
		uint _diamondCarats = uint64(
			(
				_diamondComposition - diamondSecurity % 500000
			) + 500000
		);
		uint _diamondOrigin = uint16(
			_diamondComposition % 15
		);
		uint _diamondQuality = uint16(
			(
				_diamondComposition % 500
			) + 500
		);
		uint _diamondClarity = uint16(
			uint256(
				(
					_diamondComposition - diamondSecurity
				) % 500
			) + 250
		);
		uint _diamondShape = uint16(
			uint256(
				(
					_diamondComposition * diamondSecurity
				) % 125
			)
		);
		uint id = diamonds.push(
			Diamond(
				uint256(_diamondComposition), 
				uint64(_diamondColor), 
				uint16(_diamondCarats), 
				uint16(_diamondOrigin), 
				uint16(_diamondQuality), 
				uint16(_diamondClarity), 
				uint16(_diamondShape)
			)
		);
		diamondToOwner[id] = msg.sender;
		ownerDiamondCount[msg.sender]++;
		ownerDice[msg.sender] = uint256(
			(
				uint256(
					ownerDice[msg.sender]
				) - diamondSecurity
			)
		);
		emit NewDiamond(
			id, 
			uint256(_diamondComposition), 
			uint64(_diamondColor), 
			uint16(_diamondOrigin), 
			uint64(_diamondCarats), 
			uint16(_diamondQuality), 
			uint16(_diamondClarity), 
			uint16(_diamondShape)
		);
	}
	
	function _createDiamond(uint256 _diamondComposition) private {
			uint _diamondColor = uint64(
				_diamondComposition % 1000000
			);
			uint _diamondCarats = uint64(
				uint256(
					(
						_diamondComposition + diamondSecurity
					) % 1000000
				)
			);
			uint _diamondOrigin = uint16(
				_diamondComposition % 15 + 1
			);
			uint _diamondQuality = uint16(
				(
					_diamondComposition - uint64(
						ownerDice[msg.sender]
					)
				) % 1000000
			);
			uint _diamondClarity = uint16(
				uint256(
					(
						_diamondComposition * diamondSecurity - diamondSecurity
					) % 100
				)
			);
			uint _diamondShape = uint16(
				uint256(
					(
						_diamondComposition * diamondSecurity
					) % 100
				)
			);
			uint id = diamonds.push(
				Diamond(
					uint256(_diamondComposition), 
					uint64(_diamondColor), 
					uint16(_diamondCarats), 
					uint16(_diamondOrigin), 
					uint16(_diamondQuality), 
					uint16(_diamondClarity), 
					uint16(_diamondShape)
					)
				);
			diamondToOwner[id] = msg.sender;
			ownerDiamondCount[msg.sender] = ownerDiamondCount[msg.sender] + 1;
			ownerDice[msg.sender] = uint256(
				(
					uint256(
						ownerDice[msg.sender]
					) - diamondSecurity
				)
			);
			emit NewDiamond(
				id, 
				uint256(_diamondComposition), 
				uint64(_diamondColor), 
				uint16(_diamondOrigin), 
				uint64(_diamondCarats), 
				uint16(_diamondQuality), 
				uint16(_diamondClarity), 
				uint16(_diamondShape)
			);
		}
	
	function _generateDiamondComposition(uint _size) private returns (uint) {
	    ownerDice[msg.sender] = uint256(
			(
				uint256(
					ownerDice[msg.sender]
				) - diamondSecurity
			)
		);
	    uint sizeConversion = ownerDice[msg.sender];
	    _size = uint256(
			keccak256(sizeConversion)
		);
	    return _size;
	}
	
	function getDice() external payable {
	    require(
			diamondLocked != 0
		);
	    require(
			ownerDice[msg.sender] == 0
		);
	    require(
			msg.value == diceFee
		);
	    bytes32 addressToBytes = toBytes(msg.sender);
	    uint bytesToInteger = uint(addressToBytes);
	    uint diceFinalInteger = uint(keccak256(bytesToInteger));
	    ownerDice[msg.sender] = uint256(
			diceFinalInteger - diamondSecurity
		);
	}
	
	function mineCoal() external payable needsDice {
	    require(
			msg.value == coalFee
		);
	    ownerDice[msg.sender] = uint256(
			ownerDice[msg.sender] - 1
		);
	    uint compositionPush = uint256(
			ownerDice[msg.sender]
		);
	    uint randomDiamondComposition = _generateDiamondComposition(compositionPush);
	    randomDiamondComposition = randomDiamondComposition + uint256(keccak256(now));
	    _createDiamond(randomDiamondComposition);
	    ownerDice[msg.sender]++;
	}
}