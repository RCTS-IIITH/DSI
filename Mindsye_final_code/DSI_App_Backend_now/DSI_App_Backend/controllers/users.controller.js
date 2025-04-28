

import {Professional} from '../models/professional.model.js';
import {School} from '../models/school.model.js';
import {ngoAdmin} from '../models/ngo.model.js';
import {Report} from '../models/report.model.js';
import {Teacher} from '../models/teacher.model.js';
import {Child} from '../models/child.model.js';
import { schoolAdmin } from '../models/schoolAdmin.js';

import Submission from "../models/submissionmodel.js"; 

const responder = (req, res) => {
    res.status(200).json({ message: "Hello World" });
};

const createProfessionalAccount = async (req, res) => {
    const data = req.body;
    console.log(data);
    try {
        const name = data.name;
        const Number = data.phone;
        const Address = data.address;
        const ProfessionalID = data.professionalId;
        const professional = new Professional({ name, Number, Address, ProfessionalID });
        await professional.save();
    }
    catch (error) {
        console.log(error);
        res.status(500).json({ message: "Error Creating Professional Account" });
    }
    res.status(200).json({ message: "Professional Account Created" });
}

const getProfessionalIds = async (req, res) => {
    try {
        // const professionals = await Professional.find({}, { ProfessionalID: 1 } 
        // get all fields
        // const data = await Professional.find({});
        // get name and ProfessionalID fields
        const data = await Professional.find({}, { name: 1, ProfessionalID: 1 });
        console.log(data);
        res.status(200).json(data);
    }
    catch (error) {
        console.log(error);
        res.status(500).json({ message: "Error Fetching Professional Ids" });
    }
}

const createSchoolAccount = async (req, res) => {
    const data = req.body;
    console.log(data);
    try {
        const schoolName = data.schoolName;
        const UDISE = data.udiseNumber;
        const address = data.address;
        const assignedProfessional = data.assignedProfessionalId;
        // const school = new School({ name, Number, Address });
        const school = new School({ schoolName, UDISE, address, assignedProfessional });
        await school.save();
    }
    catch (error) {
        console.log(error);
        res.status(500).json({ message: "Error Creating School Account" });
    }
    res.status(200).json({ message: "School Account Created" });
}

const getSchoolAdmins = async (req, res) => {
    try {
      const data = await schoolAdmin.find({});
      console.log(data);
      res.status(200).json(data);
    } catch (error) {
      console.log(error);
      res.status(500).json({ message: 'Error Fetching School Admins' });
    }
  };
  
  const createSchoolAdmin = async (req, res) => {
    try {
      const { name, number } = req.body;
  
      if (!name || !number) {
        return res.status(400).json({ message: 'Name and number are required' });
      }
  
      const newAdmin = await schoolAdmin.create({ name, number });
      console.log(newAdmin);
      res.status(201).json(newAdmin);
    } catch (error) {
      console.log(error);
      res.status(500).json({ message: 'Error Creating School Admin' });
    }
  };
  
const createNgoAdminAccount = async (req, res) => {
    const data = req.body;
    console.log(data);
    try {
        const name = data.name;
        const number = data.phone;
        // add empty assignedSchoolList

        const ngo = new ngoAdmin({ name, number });
        await ngo.save();
    }
    catch (error) {
        console.log(error);
        res.status(500).json({ message: "Error Creating NGO Admin Account" });
    }
    res.status(200).json({ message: "NGO Admin Account Created" });
}

const assignAdminToSchool = async (req, res) => {
    const data = req.body;
    console.log(data);
    try{
        // modify the admin object to add the school to the assignedSchoolList
        const adminName = data.adminName;
        const schoolName = data.schoolName;

        const admin = await ngoAdmin.findOne({name: adminName});
        console.log(admin);
        admin.assignedSchoolList.push(schoolName);
        await admin.save();
    }
    catch (error) {
        console.log(error);
        res.status(500).json({ message: "Error Assigning Admin to School" });
    }
    res.status(200).json({ message: "Admin Assigned to School" });
}

const getAdmins = async (req, res) => {
    try {
        const data = await ngoAdmin.find({});
        console.log(data);
        res.status(200).json(data);
    }
    catch (error) {
        console.log(error);
        res.status(500).json({ message: "Error Fetching Admins" });
    }
}

const getSchools = async (req, res) => {
    try {
        const data = await School.find({});
        console.log(data);
        res.status(200).json(data);
    }
    catch (error) {
        console.log(error);
        res.status(500).json({ message: "Error Fetching Schools" });
    }
}


const uploadteacherdetails = async (req, res) => {  
    try {
        const data = req.body;
        console.log(data);

        // Find the school by name
        const school = await School.findOne({ schoolName: data.school });

        if (!school) {
            return res.status(400).json({ message: "School not found" });
        }

        // Create a new teacher with the correct fields
        const teacher = new Teacher({
            name: data.name,
            class: parseInt(data.class), // schema expects Number
            phone: data.phone,
            school_name: school.schoolName  // ✅ Correct key and value
        });
        

        await teacher.save();

        // Add the teacher's ID to the school's teachers array
        school.teachers = school.teachers || []; // Ensure it's an array
        school.teachers.push(teacher._id);
        await school.save();

        res.status(200).json({ message: "Teacher Account Created", teacher });

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Error Creating Teacher Account" });
    }
};
const getAllTeachers = async (req, res) => {
    try {
        const teachers = await Teacher.find(); // Fetch all teachers
        res.status(200).json(teachers);
    } catch (error) {
        res.status(500).json({ message: "Error fetching teachers", error });
    }
};

const uploadchilddetails = async (req, res) => {
    try {
        const { name, rollNumber, schoolID, parentName, parentPhoneNumber, class: classNum, age } = req.body;

        if (!name || !age) {
            return res.status(400).json({ message: "Name and Age are required" });
        }

        const child = new Child({
            name,
            rollNumber,
            schoolID,
            parentName,
            parentPhoneNumber,
            class: classNum,
            age
        });

        await child.save();
        res.status(201).json({ message: "Child added successfully", child });

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Error adding child" });
    }
};




// Fetch reports for a specific user



//const getchilddetails = async (req, res) => {
  //  try {
    //    const children = await Child.find();
      //  res.status(200).json(children);
    //} catch (error) {
      //  console.error(error);
       // res.status(500).json({ message: "Error fetching children" });
  //  }
//};
const getchilddetails = async (req, res) => {
    try {
        const { phone, role } = req.query;

        if (!role) {
            return res.status(400).json({ message: "Role is required" });
        }

        let children = [];

        if (role === "Parent") {
            if (!phone) {
                return res.status(400).json({ message: "Phone number is required for parents" });
            }

            // Fetch children where parent's phone number matches exactly
            children = await Child.find({ parentPhoneNumber: phone });
        } else if (role === "Teacher") {
            // Fetch all children for teachers
            children = await Child.find();
        } else {
            return res.status(400).json({ message: "Invalid role" });
        }

        res.status(200).json(children);
    } catch (error) {
        console.error("Error fetching children:", error);
        res.status(500).json({ message: "Error fetching children" });
    }
};


const storeReportData = async (req, res) => {
  try {
    console.log("Request Body:", req.body); // Log incoming request data

    const data = req.body;

    // Extract submittedBy object
    const submittedBy = data.submittedBy;
    if (submittedBy.id && !submittedBy.phone) {
      submittedBy.phone = submittedBy.id;
    }
    
    if (!submittedBy || !submittedBy.role || !submittedBy.phone) {
      console.error("User information is missing or invalid.");
      return res.status(400).json({ error: "User information is missing or invalid." });
    }

    console.log("Submitted By:", submittedBy); // Log submittedBy object

    // Parse nested objects (houseAns, personAns, treeAns)
    let houseAns, personAns, treeAns;
    try {
      houseAns = typeof data.houseAns === 'string' ? JSON.parse(data.houseAns) : data.houseAns;
      personAns = typeof data.personAns === 'string' ? JSON.parse(data.personAns) : data.personAns;
      treeAns = typeof data.treeAns === 'string' ? JSON.parse(data.treeAns) : data.treeAns;
    } catch (error) {
      console.error("Error parsing nested objects:", error);
      return res.status(400).json({ error: "Invalid format for nested objects (houseAns, personAns, treeAns)." });
    }

    console.log("House Answers:", houseAns); // Log grouped answers
    console.log("Person Answers:", personAns);
    console.log("Tree Answers:", treeAns);

    // Validate required fields in nested objects
    const requiredFields = [
      "WhoLivesHere",
      "ArethereHappy",
      "DoPeopleVisitHere",
      "Whatelsepeoplewant",
      "Whoisthisperson",
      "Howoldarethey",
      "Whatsthierfavthing",
      "Whattheydontlike",
      "Whatkindoftree",
      "howoldisit",
      "whatseasonisit",
      "anyonetriedtocut",
      "whatelsegrows",
      "whowaters",
      "doesitgetenoughsunshine",
    ];

    const missingFields = requiredFields.filter(
      (field) => !(houseAns[field] || personAns[field] || treeAns[field])
    );
    if (missingFields.length > 0) {
      console.error("Missing Fields:", missingFields);
      return res.status(400).json({
        error: "The following fields are missing:",
        missingFields,
      });
    }

    // Extract role-specific fields
    let clinicsName = "";
    let childsName = "";
    let age = null;
    let optionalNotes = "";
    let flagforlabel = false; // Default to false
    let labelling = "";

    // Populate role-specific fields only for Professionals
    if (submittedBy.role === "Professional") {
      clinicsName = data.clinicsName || "";
      childsName = data.childsName || "";
      age = data.age || null;
      optionalNotes = data.optionalNotes || "";
      flagforlabel = typeof data.flagforlabel === "string"
        ? data.flagforlabel.toLowerCase() === "true"
        : !!data.flagforlabel; // Handle both string and Boolean inputs
      labelling = data.labelling || "";
    } else if (submittedBy.role === "Parent" || submittedBy.role === "Teacher") {
      // Validate child data for Parent and Teacher
      if (!data.childsName || !data.age) {
        return res.status(400).json({
          error: "Child name and age are required for Parent and Teacher roles.",
        });
      }
      childsName = data.childsName;
      age = data.age;
    }

    // Create the report object
    const report = new Report({
      clinicsName,
      childsName,
      age,
      optionalNotes,
      flagforlabel,
      labelling,
      imageurl: data.imageurl || "",
      houseAns,
      personAns,
      treeAns,
      submittedBy, // Include the submittedBy object
    });

    console.log("Report Object:", report); // Log the report object

    // Save the report
    await report.save();
    console.log("Report Saved Successfully"); // Log successful save

    // Respond with success
    return res.status(201).json({
      message: "Report submitted successfully.",
      report,
    });
  } catch (error) {
    console.error("Error storing report data:", error); // Log the error

    // Handle validation errors explicitly
    if (error.name === "ValidationError") {
      const validationErrors = Object.values(error.errors).map((err) => err.message);
      return res.status(400).json({
        error: "Validation failed.",
        details: validationErrors,
      });
    }

    // Ensure only one response is sent
    if (!res.headersSent) {
      return res.status(500).json({
        error: "An error occurred while processing the report.",
      });
    }
  }
};

const getsubmissionsummary = async (req, res) => {  
  try {
    const { role, phone } = req.query;

    if (!role) {
      return res.status(400).json({ error: "Role is required" });
    }

    let query = {};
    if (role === "Parent") {
      if (!phone) {
        return res.status(400).json({ error: "Phone number is required for parents" });
      }
      query = { "submittedBy.phone": phone };
    }

    // Aggregate submissions by child name
    const summary = await Report.aggregate([
      { $match: query },
      {
        $group: {
          _id: "$childsName",
          submissionCount: { $sum: 1 },
        },
      },
      {
        $project: {
          childsName: "$_id",
          submissionCount: 1,
          _id: 0,
        },
      },
    ]);

    res.status(200).json(summary);
  } catch (error) {
    console.error("Error fetching submission summary:", error);
    res.status(500).json({ error: "Error fetching submission summary" });
  }
};

// Endpoint 2: Fetch Submissions by Child Name
const getSubmissionsByChild = async (req, res) => {

  try {
    const { role, phone, childsName } = req.query;

    if (!role || !childsName) {
      return res.status(400).json({ error: "Role and child name are required" });
    }

    let query = { childsName };
    if (role === "Parent") {
      if (!phone) {
        return res.status(400).json({ error: "Phone number is required for parents" });
      }
      query["submittedBy.phone"] = phone;
    }

    // Fetch submissions for the specific child
    const submissions = await Report.find(query, {
      childsName: 1,
      age: 1,
      submittedAt: 1,
      houseAns: 1,
      personAns: 1,
      treeAns: 1,
    }).sort({ submittedAt: -1 });

    res.status(200).json(submissions);
  } catch (error) {
    console.error("Error fetching submissions by child:", error);
    res.status(500).json({ error: "Error fetching submissions by child" });
  }
};



  const searchNumber = async (req, res) => {
    console.log("📢 Request received at /api/users/search-number");
    const data = req.body;

    try {
        const usertype = data.usertype;
        const number = data.number;

        if (usertype == "NGO Master") {
            const admin = await ngoAdmin.findOne({ number: number });
            if (!admin) {
                return res.status(500).json({ message: "NGO Admin Not Found" });
            }
            return res.status(200).json(admin);

        } else if (usertype == "Teacher") {
            const teacher = await Teacher.findOne({ phone: number });
            if (!teacher) {
                return res.status(500).json({ message: "Teacher Not Found" });
            }
            return res.status(200).json(teacher);

        } else if (usertype == "Professional") {
            const professional = await Professional.findOne({ Number: number });
            if (!professional) {
                return res.status(500).json({ message: "Professional Not Found" });
            }
            return res.status(200).json(professional);

        } else if (usertype == "Parent") {
            const parent = await Child.findOne({ parentPhoneNumber: number });
            if (!parent) {
                return res.status(500).json({ message: "Parent Not Found" });
            }
            return res.status(200).json(parent);

        } else if (usertype == "School Admin" || usertype == "Admin") {
          const admin = await schoolAdmin.findOne({ number: number });
          if (!admin) {
              return res.status(500).json({ message: "School Admin Not Found" });
          }
          return res.status(200).json(admin);
      }
       else {
          return res.status(400).json({ message: "Invalid usertype" });
      }

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Error Fetching User" });
    }
};


export default responder;
export { createProfessionalAccount,
    getProfessionalIds, 
    createSchoolAccount, 
    createNgoAdminAccount,
    assignAdminToSchool,
    getAdmins,
    getSchools,
    storeReportData,
    uploadteacherdetails,
    getAllTeachers,
    getchilddetails,
    uploadchilddetails,
    getSubmissionsByChild,
    getsubmissionsummary ,
    getsubmissions,
    getallstudentsubmissions,
    searchNumber,
    getSchoolAdmins, createSchoolAdmin,

};
