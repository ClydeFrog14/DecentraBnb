// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract DecentraBnB {

    // Definitions //

    address payable renterAddress;
    address payable propertyOwnerAddress;


    struct rentalProperty {
        uint256 id;
        uint256 priceDaily;
        uint256 maxGuests;
        address currentRenter;
        string propertyType;
        string city;
        string propertyDescription;
        string coordinates;
        bool rentalAvailability;
        uint256 sumOfRatings;
        uint256 numberOfRatings;
        uint256 AverageRating;
    }

    rentalProperty[] public rentals; //Dynamic size

    // Events //

    event newResevation(address indexed renterAddress, uint256 id, uint256 _numberOfDays, uint256 timestamp); // This event will be emited when a property is rented
    event newCheckOut(address indexed renterAddress, uint256 id, uint256 timestamp);                          // This event will be emited when traveller checks-out.
    event canceledBooking(address indexed renterAddress, uint256 id, uint256 amount, uint256 timestamp);      // This event will be emited when traveller or host cancels the booking.


    //Using a modifier because we will want some functions to be called only by "Property Owner"
    modifier onlyPropertyOwner {
        require(msg.sender == propertyOwnerAddress, "Only Property Owner Can Call This!");
        _;
    }
    modifier onlyRenter {
        require(msg.sender == renterAddress, "Only Renter Can Call This!");
        _;
    }

    //Variables that needs to be runned only once will be located in "Constructor"
    constructor() {

        propertyOwnerAddress = payable(msg.sender); // Since "Property Owner" is creating the contract

        //Below, we only set 2 properties assuming the host has only 2 properties.

        rentals[1].id = 36483010;
        rentals[1].priceDaily = 0.15 ether;
        rentals[1].maxGuests = 3;
        rentals[1].currentRenter = address(0);
        rentals[1].propertyType = "Studio";
        rentals[1].city = "Geneva";
        rentals[1].propertyDescription = "Peaceful studio with Jet d'Eau Fountain view";
        rentals[1].coordinates = "40.72585, -73.94001";
        rentals[1].rentalAvailability = true;
        rentals[1].sumOfRatings = 0;
        rentals[1].numberOfRatings = 0;
        rentals[1].AverageRating = 0;


        rentals[2].id = 36483011;
        rentals[2].priceDaily = 1.0 ether;
        rentals[2].maxGuests = 6;
        rentals[2].currentRenter = address(0);
        rentals[2].propertyType = "Villa";
        rentals[2].city = "Geneva";
        rentals[2].propertyDescription = "Villa by the Lake Geneva with heated pool near Versoix";
        rentals[2].coordinates = "41.94585, -72.95345";
        rentals[2].rentalAvailability = true;
        rentals[2].sumOfRatings = 0;
        rentals[2].numberOfRatings = 0;
        rentals[2].AverageRating = 0;

    }


    // Functions //
        // Rent Function //
    function rentProperty(uint256 _rental, uint256 _numberOfDays) public payable onlyRenter returns(string memory){
        renterAddress = payable(msg.sender);

        if((_numberOfDays * rentals[_rental].priceDaily == msg.value) && (rentals[_rental].rentalAvailability = true)){
            changeRentalAvailability(_rental, false);
            rentals[_rental].currentRenter = renterAddress;
            propertyOwnerAddress.transfer(msg.value);
            emit newResevation(msg.sender, rentals[_rental].id, _numberOfDays, block.timestamp);
        return "Property is booked!";
        } else {
            renterAddress.transfer(msg.value);
        return "Please retry: Check the number of days of your stay or the amount you are paying";
        } 
    }    

        // Check Out Function //
    function checkOut(uint256 _rental, uint256 _rating) public onlyRenter {
        //Rating part
        require(_rating <= 10 && _rating >= 1, "Please try again and give a rating between 1-10.");
        rentals[_rental].sumOfRatings = rentals[_rental].sumOfRatings + _rating;
        rentals[_rental].numberOfRatings++;
        rentals[_rental].AverageRating = rentals[_rental].sumOfRatings / rentals[_rental].numberOfRatings;
        //Variables back to normal
        rentals[_rental].currentRenter = address(0);
        changeRentalAvailability(_rental, true);
        //Emit the event
        emit newCheckOut(msg.sender, rentals[_rental].id, block.timestamp);
    }

        //Cancel Booking Function //
    function cancelBooking(uint256 _rental) public payable{
        renterAddress.transfer(msg.value);
        rentals[_rental].currentRenter = address(0);
        changeRentalAvailability(_rental, true);
        //Emit the event
        emit canceledBooking(msg.sender, rentals[_rental].id, block.timestamp, msg.value);
    }

        // Getter Functions //
    function checkIfAvailable(uint256 _rental) view public returns(bool){
        return rentals[_rental].rentalAvailability;
    }
    function checkCurrentRenter(uint256 _rental) view public returns(address){
        return rentals[_rental].currentRenter;
    }
    function checkPriceDaily(uint256 _rental) view public returns(uint256){
        return rentals[_rental].priceDaily;
    }
    function checkId(uint256 _rental) view public returns(uint256){
        return rentals[_rental].id;
    }
    function checkMaxGuests(uint256 _rental) view public returns(uint256){
        return rentals[_rental].maxGuests;
    }
    function checkPropertyType(uint256 _rental) view public returns(string memory){
        return rentals[_rental].propertyType;
    }
    function checkCity(uint256 _rental) view public returns(string memory){
        return rentals[_rental].city;
    }
    function checkPropertyDescription(uint256 _rental) view public returns(string memory){
        return rentals[_rental].propertyDescription;
    }
    function checkCoordinates(uint256 _rental) view public returns(string memory){
        return rentals[_rental].coordinates;
    }
    function checkAverageRating(uint256 _rental) view public returns(uint256){
        return rentals[_rental].AverageRating;
    }
    function checkNumberOfRatings(uint256 _rental) view public returns(uint256){
        return rentals[_rental].numberOfRatings;
    }
    
        // Setter Functions //
    function changeRentalAvailability(uint256 _rental, bool _new) onlyPropertyOwner public {
        rentals[_rental].rentalAvailability = _new;
        if(_new == true){
            rentals[_rental].currentRenter = address(0);
        }
    }

    function changePriceDaily(uint256 _rental, uint256 _price) onlyPropertyOwner public {
        rentals[_rental].priceDaily = _price;
    }

    function changemaxGuests(uint256 _rental, uint256 _maxGuests) onlyPropertyOwner public {
        rentals[_rental].maxGuests = _maxGuests;
    }

    function changePropertyType(uint256 _rental, string memory _newType) onlyPropertyOwner public {
        rentals[_rental].propertyType = _newType;
    }

    function changePropertyDescription(uint256 _rental, string memory _newDescription) onlyPropertyOwner public {
        rentals[_rental].propertyDescription = _newDescription;
    }
    
    function changeCoordinates(uint256 _rental, string memory _newCoordinates) onlyPropertyOwner public {
        rentals[_rental].coordinates = _newCoordinates;
    }

} // Contract End
