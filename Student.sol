pragma solidity ^0.5.3;

pragma experimental ABIEncoderV2;

import "./Token.sol";


contract Diploma {
    address private owner;
    address private token;

    struct Establishment {
        bool exists;
        uint256 ees_id;
        string establishment_name;
        string establishment_type;
        string country;
        string addresses;
        string website;
        uint256 agent_id;
    }

    struct StudentPersonalInfo {
        string LastName;
        string FirstName;
        string DateOfBirth;
        string Gender;
        string Nationality;
        string MaritalStatus;
        string Address;
        string Email;
        string Phone;
    }

    struct StudentAcademicInfo {
        string Section;
        string ThesisTopic;
        string InternshipCompany;
        string InternshipSupervisor;
        string InternshipStartDate;
        string InternshipEndDate;
        string Evaluation;
    }

    struct Student {
        bool exists;
        uint256 student_id;
        StudentPersonalInfo personalInfo;
        StudentAcademicInfo academicInfo;
    }

    struct Company {
        bool exists;
        uint256 diploma_id;
        uint256 company_id;
        string Name;
        string Sector;
        string DateOfCreation;
        string SizeClassification;
        string Country;
        string Address;
        string Email;
        string Phone;
        string Website;
    }

    struct DiplomaInfo {
        bool exists;
        uint256 holder_id;
        string institution_name;
        string country;
        string diploma_type;
        string specialization;
        string honors;
        string date_of_obtention;
    }

    mapping(uint256 => Establishment) public Establishments;
    mapping(address => uint256) AddressEstablishments;
    mapping(uint256 => Student) public Students;
    mapping(uint256 => Company) public Companies;
    mapping(address => uint256) AddressCompanies;
    mapping(uint256 => DiplomaInfo) public Diplomas;

    uint256 public NbEstablishments;
    uint256 public NbStudents;
    uint256 public NbCompanies;
    uint256 public NbDiplomas;

    constructor(address tokenaddress) public {
        token = tokenaddress;
        owner = msg.sender; 

        NbEstablishments = 0;
        NbStudents = 0;
        NbCompanies = 0;
        NbDiplomas = 0;
    }

    function AddEstablishments(Establishment memory e, address a) private {
        NbEstablishments += 1;
        e.exists = true;
        e.ees_id += 1;
        Establishments[NbEstablishments] = e;
        AddressEstablishments[a] = NbEstablishments;
    }

    function AddCompanies(Company memory e, address a) private {
        NbCompanies += 1;
        e.exists = true;
        e.company_id += 1;
        Companies[NbCompanies] = e;
        AddressCompanies[a] = NbCompanies;
    }

    function AddStudents(Student memory e) private {
        e.exists = true;
        e.student_id += 1;
        NbStudents += 1;
        Students[NbStudents] = e;
    }


    function AddDiplomas(DiplomaInfo memory d) private {
        d.exists = true;
        d.holder_id += 1;
        NbDiplomas += 1;
        Diplomas[NbDiplomas] = d;
    }

    function AddEstablishments(string memory name, string memory establishmentType, string memory country, string memory addresses, string memory website, uint256 agentId) public {
        Establishment memory e;
        e.establishment_name = name;
        e.establishment_type = establishmentType;
        e.country = country;
        e.addresses = addresses;
        e.website = website;
        e.agent_id = agentId;
        AddEstablishments(e, msg.sender);
    }

    function AddCompanies(string memory name, string memory sector, string memory dateOfCreation, string memory sizeClassification, string memory country, string memory companyAddress, string memory email, string memory phone, string memory website) public {
        Company memory e;
        e.Name = name;
        e.Sector = sector;
        e.DateOfCreation = dateOfCreation;
        e.SizeClassification = sizeClassification;
        e.Country = country;
        e.Address = companyAddress;
        e.Email = email;
        e.Phone = phone;
        e.Website = website;
        AddCompanies(e, msg.sender);
    }

 
    function AddStudents(StudentPersonalInfo memory personalInfo,StudentAcademicInfo memory academicInfo) public {
        uint256 id = AddressEstablishments[msg.sender];
        require(id != 0, "Not Establishment");
        
        Student storage e = Students[NbStudents + 1];
        e.exists = true;
        e.student_id = NbStudents + 1;
        e.personalInfo = personalInfo;
        e.academicInfo = academicInfo;
        NbStudents += 1;
    }
  
    function AddDiplomas(uint256 holderId, string memory country, string memory diplomaType, string memory specialization, string memory honors, string memory dateOfObtention) public {
        uint256 id = AddressEstablishments[msg.sender];
        require(id != 0, "Not Establishment");
        require(Students[holderId].exists == true, "Not Students");
        DiplomaInfo memory d;
        d.exists = true;
        d.holder_id = holderId;
        d.institution_name = Establishments[id].establishment_name;
        d.country = country;
        d.diploma_type = diplomaType;
        d.specialization = specialization;
        d.honors = honors;
        d.date_of_obtention = dateOfObtention;
        AddDiplomas(d);
    }


    function evaluate(uint256 studentId,string memory thesisTopic,string memory internshipCompany,string memory internshipSupervisor,string memory internshipStartDate,string memory internshipEndDate,string memory evaluation) public {
        uint256 id = AddressCompanies[msg.sender];
        require(id != 0, "No Companies");
        require(Students[studentId].exists == true, "Not Students");
        Students[studentId].academicInfo.ThesisTopic = thesisTopic;
        Students[studentId].academicInfo.InternshipCompany = internshipCompany;
        Students[studentId].academicInfo.InternshipSupervisor = internshipSupervisor;
        Students[studentId].academicInfo.InternshipStartDate = internshipStartDate;
        Students[studentId].academicInfo.InternshipEndDate = internshipEndDate;
        Students[studentId].academicInfo.Evaluation = evaluation;
        
        require(
            Token(token).allowance(owner, address(this)) >= 15, 
            "Token not allowed"
        );
        require(
            Token(token).transferFrom(owner, msg.sender, 15),
            "Transfer failed"
        );
    }


    event VerificationResult(bool success, DiplomaInfo diploma);


    function verify(uint256 diplomaId) public returns (bool, DiplomaInfo memory) {
        require(
            Token(token).allowance(msg.sender, address(this)) >= 10,
            "Token not allowed"
        );
        require(
            Token(token).transferFrom(msg.sender, owner, 10),
            "Transfer failed"
        );
        emit VerificationResult(Diplomas[diplomaId].exists, Diplomas[diplomaId]);
        return (Diplomas[diplomaId].exists, Diplomas[diplomaId]);
    }
}
