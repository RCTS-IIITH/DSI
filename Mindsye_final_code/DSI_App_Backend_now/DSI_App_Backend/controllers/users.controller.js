// Copyright 2024 Umang Patel
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     https://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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


const getSubmissions = async (req, res) => {
    try {
      const { phone, role, childId } = req.query;
  
      if (!role) {
        return res.status(400).json({ message: "Role is required" });
      }
  
      let children = [];
  
      // Determine children based on role
      if (role === "Parent") {
        if (!phone) {
          return res.status(400).json({ message: "Phone number is required for parents" });
        }
  
        // Get children linked to parent phone
        children = await Child.find({ parentPhoneNumber: phone });
      } else if (role === "Teacher") {
        // Teachers see all children
        children = await Child.find();
      } else {
        return res.status(400).json({ message: "Invalid role" });
      }
  
      const childIds = children.map(child => child._id.toString());
  
      // Filter logic
      let filter = {};
      if (childId) {
        // If specific childId is requested, override other filters
        filter.childId = childId;
      } else {
        filter.childId = { $in: childIds };
      }
  
      // Get submissions and populate child details
      const submissions = await Submission.find(filter).populate('childId');
  
      const formatted = submissions.map(sub => ({
        id: sub._id,
        childName: sub.childId?.name || 'Unknown',
        imageUrl: sub.imageUrl,
        answers: sub.answers,
        submittedAt: sub.submittedAt
      }));
  
      res.status(200).json(formatted);
    } catch (error) {
      console.error("Error fetching submissions:", error);
      res.status(500).json({ message: "Error fetching submissions" });
    }
  };

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
    const data = req.body;
    console.log(data);
    try {
        const clinicsName = "";
        const childsName = "";
        const age = null
        const optionalNotes = "";
        const flagforlabel = "";
        const labelling = "";
        const imageurl = data.imageurl;
        const WhoLivesHere = data.WhoLivesHere;
        const ArethereHappy = data.ArethereHappy;
        const DoPeopleVisitHere = data.DoPeopleVisitHere;
        const Whatelsepeoplewant = data.Whatelsepeoplewant;
        const Whoisthisperson = data.Whoisthisperson;
        const Howoldarethey = data.Howoldarethey;
        const Whatsthierfavthing = data.Whatsthierfavthing;
        const Whattheydontlike = data.Whattheydontlike;
        const Whatkindoftree = data.Whatkindoftree;
        const howoldisit = data.howoldisit;
        const whatseasonisit = data.whatseasonisit;
        const anyonetriedtocut = data.anyonetriedtocut;
        const whatelsegrows = data.whatelsegrows;
        const whowaters = data.whowaters;
        const doesitgetenoughsunshine = data.doesitgetenoughsunshine;
        const houseAns = { WhoLivesHere, ArethereHappy, DoPeopleVisitHere, Whatelsepeoplewant };
        const personAns = { Whoisthisperson, Howoldarethey, Whatsthierfavthing, Whattheydontlike };
        const treeAns = { Whatkindoftree, howoldisit, whatseasonisit, anyonetriedtocut, whatelsegrows, whowaters, doesitgetenoughsunshine };
        console.log(houseAns);
        console.log(personAns);
        console.log(treeAns);
        const report = new Report({ clinicsName, childsName, age, optionalNotes, flagforlabel, labelling, imageurl, houseAns, personAns, treeAns });
        await report.save();
    }
    catch (error) {
        console.log(error);
        res.status(500).json({ message: "Error Storing Report Data" });
    }
    res.status(200).json({ message: "Report Data Stored" });
}

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

        } else if (usertype == "School Admin") {
            const schoolAdmin = await SchoolAdmin.findOne({ number: number });
            if (!schoolAdmin) {
                return res.status(500).json({ message: "School Admin Not Found" });
            }
            return res.status(200).json(schoolAdmin);

        } else {
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
    getSubmissions,
    searchNumber,
    getSchoolAdmins, createSchoolAdmin,

};