// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./LibShare.sol";
import "./PNDC_ERC1155.sol";
import "./TokenERC1155.sol";

interface TokenFactory1155 {
    function collectionToOwner(address) external returns (address);
}

contract NFT1155Drop is Ownable, ERC1155Holder, ReentrancyGuard {
    struct Claim {
        address moderator;
        address collection;
        uint256 tokenId;
        uint256 amount;
        uint256 endTime;
        uint256 pricePerToken;
    }

    event ClaimCreated(
        address moderator,
        address claimee,
        uint256 tokenId,
        uint256 amount,
        address collection,
        uint256 endTime
    );
    event TokensClaimed(
        address claimee,
        uint256 tokenId,
        uint256 amount,
        address collection,
        bool withinTime,
        address tokenTransferredTo
    );

    modifier onlyMod() {
        require(s_moderators[msg.sender]);
        _;
    }

    mapping(address => Claim[]) internal s_userClaims;
    mapping(address => bool) public s_moderators;
    address public PNDC;
    address public Factory;

    constructor(address _pndc, address _factory) {
        PNDC = _pndc;
        Factory = _factory;
        s_moderators[msg.sender] = true;
    }

    function createClaim(
        address _collection,
        address _claimee,
        uint256 _tokenId,
        uint256 _amount,
        uint256 _time,
        uint256 _pricePerToken
    ) external onlyMod {
        require(
            _collection == PNDC ||
                TokenFactory1155(Factory).collectionToOwner(_collection) !=
                address(0)
        );
        require(PNDC_ERC1155(_collection).balanceOf(msg.sender, _tokenId) >= _amount);
        require(_claimee != msg.sender);
        require(_time > 0);
        require(s_userClaims[_claimee].length <= 10);

        //needs approval
        PNDC_ERC1155(_collection).safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId,
            _amount,
            ""
        );

        Claim memory m_newClaim = Claim(
            msg.sender,
            _collection,
            _tokenId,
            _amount,
            block.timestamp + _time,
            _pricePerToken
        );
        s_userClaims[_claimee].push(m_newClaim);
        emit ClaimCreated(
            msg.sender,
            _claimee,
            _tokenId,
            _amount,
            _collection,
            m_newClaim.endTime
        );
    }

    function claim() external payable nonReentrant{
        uint256 m_totalClaims = s_userClaims[msg.sender].length;
        require(m_totalClaims != 0);
        uint256 totalPrice = 0;
        for (uint256 i = 0; i < m_totalClaims; ++i) {
            if(block.timestamp <= s_userClaims[msg.sender][i].endTime) {
                totalPrice += s_userClaims[msg.sender][i].pricePerToken * s_userClaims[msg.sender][i].amount;
            }
        }
        require(msg.value == totalPrice);
        for (uint256 i = 0; i < m_totalClaims; ++i) {
            if (block.timestamp <= s_userClaims[msg.sender][i].endTime) {
                (bool isSuccess, ) = payable(
                    s_userClaims[msg.sender][i].moderator
                ).call{value: (s_userClaims[msg.sender][i].pricePerToken * s_userClaims[msg.sender][i].amount)}("");
                require(isSuccess, "Transfer failed");
                PNDC_ERC1155(s_userClaims[msg.sender][i].collection)
                    .safeTransferFrom(
                        address(this),
                        msg.sender,
                        s_userClaims[msg.sender][i].tokenId,
                        s_userClaims[msg.sender][i].amount,
                        ""
                    );
                emit TokensClaimed(
                    msg.sender,
                    s_userClaims[msg.sender][i].tokenId,
                    s_userClaims[msg.sender][i].amount,
                    s_userClaims[msg.sender][i].collection,
                    true,
                    msg.sender
                );
            } else {
                PNDC_ERC1155(s_userClaims[msg.sender][i].collection)
                    .safeTransferFrom(
                        address(this),
                        s_userClaims[msg.sender][i].moderator,
                        s_userClaims[msg.sender][i].tokenId,
                        s_userClaims[msg.sender][i].amount,
                        ""
                    );
                emit TokensClaimed(
                    msg.sender,
                    s_userClaims[msg.sender][i].tokenId,
                    s_userClaims[msg.sender][i].amount,
                    s_userClaims[msg.sender][i].collection,
                    false,
                    s_userClaims[msg.sender][i].moderator
                );
            }
        }
        delete s_userClaims[msg.sender];
    }

    function getClaims(address _claimee) external view returns(Claim[] memory claims) {
        claims = s_userClaims[_claimee];
        return claims;
    }

    function addMod(address _mod) external onlyOwner {
        require(s_moderators[_mod] == false);
        s_moderators[_mod] = true;
    }

    function removeMod(address _mod) external onlyOwner {
        require(s_moderators[_mod] == true);
        s_moderators[_mod] = false;
    }

    function changeFactory(address _factory) external onlyOwner {
        Factory = _factory;
    }

    function changePNDC(address _pndc) external onlyOwner {
        PNDC = _pndc;
    }
}