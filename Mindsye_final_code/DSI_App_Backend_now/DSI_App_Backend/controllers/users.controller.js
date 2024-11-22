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
    const data = req.body;
    console.log(data);

    // now store this data in mongodb
    try {
        const name = data.name;
        const classs = data.class;
        const Number = data.phone;
        const school = data.school;
        const teacher = new Teacher({
            name: name,
            class: classs,
            Number: Number,
            school: school,
        });
        await teacher.save();
    }
    catch (error) {
        console.log(error);
        res.status(500).json({ message: "Error Creating Teacher Account" });
    }


    // //  now add teachers number into the school
    // // find the school first
    const school = await School.findOne({schoolName: data.school});
    console.log(school);

    // add the teacher number to the school
    school.teachers.push(data.phone);

    await school.save();
    res.status(200).json({ message: "Teacher Account Created" });


}

const uploadchilddetails = async (req, res) => {
    const data = req.body;
    console.log(data);


    // save this in mongodb
    try {
        const name = data.name;
       const uid = data.uid;
       const phone = data.phone;
       const classs = data.class;
       const school = data.school;
       const dob = data.dob;
        const child = new Child({
            name: name,
            childuid: uid,
            parentphonenumber: phone,
            class: classs,
            school: school,
            dateofbirth: dob
        });
        await child.save();
    }
    catch (error) {
        console.log(error);
        res.status(500).json({ message: "Error Creating Child Account" });
    }
    res.status(200).json({ message: "Child Account Created" });
}

const storeReportData = async (req, res) => {
    const data = req.body;
    console.log(data);
    try {
        const clinicsName = data.clinicsName;
        const childsName = data.childsName;
        const age = data.age;
        const optionalNotes = data.optionalNotes;
        const flagforlabel = data.flagforlabel;
        const labelling = data.labelling;
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
    console.log("hello");
    // return res.status(200).json({ message: "Hello World" });
    const data = req.body;
    // console.log(data);
    try {
        const usertype = data.usertype;
        const number = data.number;
        if(usertype=="NGO Master"){
            const admin = await ngoAdmin.findOne({number: number});
            console.log("hhshs ",admin);
            if(admin==null){
                console.log("Erroasdasdasda");
                res.status(500).json({ message: "Error Fetching User" });
                return;
            }
            console.log(admin);
            res.status(200).json(admin);        
        }else if(usertype=="Teacher"){
            const school = await Teacher.findOne({Number: number});
            if(school==null){
                res.status(500).json({ message: "Error Fetching User" });
                return;
            }
            console.log(school);
            res.status(200).json(school);
        }else if(usertype=="Professional"){
            const professional = await Professional.findOne({Number: number});
            if(professional==null){
                res.status(500).json({ message: "Error Fetching User" });
                return;
            }
            console.log(professional);
            res.status(200).json(professional);
        }else if(usertype=="Parent"){
            const parent=await Child.findOne({parentPhoneNumber: number});
            if(parent==null){
                res.status(500).json({ message: "Error Fetching User" });
                return;
            }
            console.log(parent);
            res.status(200).json(parent);
        }else{
            res.status(500).json({ message: "Error Fetching User" });
        }

        // const data = await Professional
    }
    catch (error) {
        console.log(error);
        res.status(500).json({ message: "Error Fetching Professional Ids" });
    }
}

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
    uploadchilddetails,
    searchNumber
};