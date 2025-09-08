import {Professional} from '../models/professional.model.js';
import {School} from '../models/school.model.js';
import { HOUSE_QUESTIONS, PERSON_QUESTIONS, TREE_QUESTIONS } from '../models/questions.js';
import {Report} from '../models/report.model.js';
import {Teacher} from '../models/teacher.model.js';
import {Child} from '../models/child.model.js';
import {User} from '../models/user.model.js';

const responder = (req, res) => {
    res.status(200).json({ message: "Hello World" });
};

const createProfessionalAccount = async (req, res) => {
  const data = req.body;
  console.log(data);

  try {
    // Validate required fields
    if (!data.name || !data.Number || !data.Address || !data.ProfessionalID || !data.workEmail) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    // Check for existing ProfessionalID
    const existing = await Professional.findOne({ ProfessionalID: data.ProfessionalID });
    if (existing) {
      return res.status(400).json({ message: "ProfessionalID already exists" });
    }

    // Create professional
    const professional = new Professional({
      name: data.name,
      Number: data.Number,
      Address: data.Address,
      ProfessionalID: data.ProfessionalID,
      workEmail: data.workEmail, // New field for work email
      clinicName: data.clinicName, // Add clinicName
    });

    await professional.save();
    res.status(201).json({ message: "Professional account created successfully" });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Error Creating Professional Account" });
  }
};


// Get all assigned schools for a professional
const getAssignedSchoolsForProfessional = async (req, res) => {
  const { phoneNumber } = req.query;

  if (!phoneNumber) {
    return res.status(400).json({ success: false, error: "Phone number is required" });
  }

  try {
    const professional = await Professional.findOne({ Number: phoneNumber });

    if (!professional) {
      return res.status(404).json({ success: false, error: "Professional not found" });
    }

    // ✅ Query schools where professional._id is in School.assignedProfessionals
    const assignedSchools = await School.find(
      { assignedProfessionals: professional._id },
      { schoolName: 1 }
    );

    if (!assignedSchools || assignedSchools.length === 0) {
      return res.status(200).json({
        success: true,
        data: [],
        message: "No schools assigned to this professional",
      });
    }

    res.status(200).json({
      success: true,
      data: assignedSchools.map(s => s.schoolName),
      message: "Assigned schools fetched successfully",
    });

  } catch (error) {
    console.error(`Error fetching assigned schools: ${error.message}`);
    res.status(500).json({ success: false, error: "Server error" });
  }
};


// Assign a school to a professional (and vice versa)
const assignSchoolToProfessional = async (req, res) => {
  const { professionalId, schoolName } = req.body;

  // Validate inputs
  if (!professionalId || !schoolName) {
    return res.status(400).json({
      success: false,
      error: "Both 'professionalId' and 'schoolName' are required.",
    });
  }

  try {
    // 1. Find professional by ProfessionalID (string like "96")
    const professional = await Professional.findOne({ ProfessionalID: professionalId });
    if (!professional) {
      return res.status(404).json({
        success: false,
        error: "Professional not found",
      });
    }

    // 2. Find school by schoolName
const school = await School.findOne({ schoolName: schoolName });
if (!school) {
  return res.status(404).json({
    success: false,
    error: "School not found",
  });
}

// 3. Prevent duplicate assignments
const alreadyInProfessional = professional.assignedSchools.includes(school._id); // ✅ Compare with ObjectId
const alreadyInSchool = school.assignedProfessionals.some(
  (id) => id.toString() === professional._id.toString()
);

    if (alreadyInProfessional && alreadyInSchool) {
      return res.status(200).json({
        success: true,
        message: "School is already assigned to this professional.",
      });
    }

    // 4. Update both collections
    if (!alreadyInProfessional) {
      await Professional.updateOne(
        { ProfessionalID: professionalId },
        { $addToSet: { assignedSchools: school._id } }
      );
    }

    if (!alreadyInSchool) {
      await School.updateOne(
        { schoolName: schoolName },
        { $addToSet: { assignedProfessionals: professional._id } }
      );
    }

    // ✅ Success response
    res.status(200).json({
      success: true,
      message: "School assigned to professional successfully",
    });

  } catch (error) {
    console.error(`Error assigning school: ${error.message}`, {
      stack: error.stack,
      body: req.body,
    });

    // 🛑 Server error
    res.status(500).json({
      success: false,
      error: "Failed to assign school to professional",
    });
  }
};
const getProfessionalIds = async (req, res) => {
  try {
    // 🔁 Find all professionals and populate their assigned schools
    const professionals = await Professional.find({})
      .populate('assignedSchools', 'schoolName'); // 👈 Populates schoolName field

    const formattedProfessionals = professionals.map(p => {
      const schoolNames = Array.isArray(p.assignedSchools)
        ? p.assignedSchools.map(s => s.schoolName || 'Unknown School')
        : [];

      return {
        name: p.name,
        Number: p.Number || 'N/A',
        ProfessionalID: p.ProfessionalID || 'N/A',
        assignedSchools: schoolNames,
        clinicName: p.clinicName || 'N/A'
      };
    });

    res.status(200).json(formattedProfessionals);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error Fetching Professional IDs" });
  }
};


const createSchoolAccount = async (req, res) => {
  const data = req.body;

  try {
    const { schoolName, udiseNumber, address, contactNumber, assignedProfessionalId } = data;

// Validation: Make schoolName, udiseNumber, and address required
if (!schoolName || !udiseNumber || !address || !contactNumber) {
  return res.status(400).json({ message: "Missing required fields" });
}

    // 2. Check for existing UDISE number
    const existingSchool = await School.findOne({ UDISE: udiseNumber });
    if (existingSchool) {
      return res.status(400).json({ message: "UDISE number already exists" });
    }

    // 3. Create the school
    
const school = new School({
  schoolName,
  UDISE: udiseNumber,
  address,
  contactNumber, // ✅ Add contact number
  assignedProfessionals: [],
});
    // 4. If professional ID provided, validate and add
    if (assignedProfessionalId) {
      // First find by ProfessionalID
      const professional = await Professional.findOne({ 
        ProfessionalID: assignedProfessionalId 
      });

      if (!professional) {
        return res.status(404).json({ message: "Professional not found" });
      }

      // Add to array (supports multiple professionals in future)
      school.assignedProfessionals.push(professional._id);
    }

    await school.save();

    // 5. Update professional's assigned schools (optional)
    if (assignedProfessionalId && professional) {
      if (!professional.assignedSchools.includes(schoolName)) {
        professional.assignedSchools.push(schoolName);
        await professional.save();
      }
    }

    res.status(201).json({
      message: "School Account Created Successfully",
      school
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error Creating School Account" });
  }
};

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



const createAdmin = async (req, res) => {
  const { name, number, role, assignedSchoolList = [] } = req.body;

  try {
    // Check if number exists
    const existingUser = await User.findOne({ number });
    if (existingUser) {
      return res.status(400).json({ message: 'Phone number already exists' });
    }

    // Proceed with creation
    const newUser = new User({ name, number, role, assignedSchoolList });
    await newUser.save();
    res.status(201).json({ message: 'Admin created successfully', user: newUser });
  } catch (error) {
    if (error.code === 11000) {
      // MongoDB duplicate key error
      return res.status(400).json({ message: 'Phone number already exists' });
    }
    console.error(error);
    res.status(500).json({ message: 'Error creating admin' });
  }
};



const assignAdminToSchool = async (req, res) => {
  const { adminNumber, schoolName } = req.body;

  if (!adminNumber || !schoolName) {
    return res.status(400).json({
      success: false,
      error: "Both 'adminNumber' and 'schoolName' are required.",
    });
  }

  try {
    const admin = await User.findOne({ number: adminNumber });
    if (!admin) {
      return res.status(404).json({ success: false, error: "Admin not found" });
    }

    const school = await School.findOne({ schoolName: schoolName });
    if (!school) {
      return res.status(404).json({ success: false, error: "School not found" });
    }

    // Prevent duplicate assignments
    const alreadyInAdmin = admin.assignedSchoolList.includes(schoolName);
    const alreadyInSchool = school.assignedAdmins?.some(
      (id) => id.toString() === admin._id.toString()
    );

    if (alreadyInAdmin && alreadyInSchool) {
      return res.status(200).json({
        success: true,
        message: "School is already assigned to this admin.",
      });
    }

    // Update both collections
    if (!alreadyInAdmin) {
      await User.updateOne(
        { number: adminNumber },
        { $addToSet: { assignedSchoolList: schoolName } }
      );
    }

    if (!alreadyInSchool) {
      await School.updateOne(
        { schoolName: schoolName },
        { $addToSet: { assignedAdmins: admin._id } }
      );
    }

    res.status(200).json({
      success: true,
      message: "School assigned to admin successfully",
    });

  } catch (error) {
    console.error(`Error assigning school: ${error.message}`);
    res.status(500).json({ success: false, error: "Server error" });
  }
};

const getAdmins = async (req, res) => {
  try {
    const { phone } = req.query;

    let admins;
    if (phone) {
      // Fetch single admin by phone number
      admins = await User.findOne({ number: phone });
    } else {
      // Fetch all admins
      admins = await User.find();
    }

    // ✅ Handle no results (single or multiple)
    if (!admins || (Array.isArray(admins) && admins.length === 0)) {
      return res.status(404).json({ message: "No admins found" });
    }

    // ✅ Normalize assignedSchoolList (ensure array format)
    const normalizeSchoolList = (list) => {
      if (Array.isArray(list)) return list;
      if (typeof list === 'string') {
        return list
          .split(',')
          .map(s => s.trim())
          .filter(Boolean);
      }
      return [];
    };

    // ✅ Sanitize and format response
    const formatAdmin = (admin) => {
      const obj = admin.toObject();
      return {
        _id: obj._id,
        name: obj.name,
        number: obj.number,
        role: obj.role,
        assignedSchoolList: normalizeSchoolList(obj.assignedSchoolList)
      };
    };

    // ✅ Return appropriate response
    if (phone) {
      return res.status(200).json(formatAdmin(admins));
    } else {
      return res.status(200).json(admins.map(formatAdmin));
    }

  } catch (error) {
    console.error(`Error fetching admins: ${error.message}`, {
      stack: error.stack
    });
    return res.status(500).json({ message: "Internal Server Error" });
  }
};
const getAllAdmins = async (req, res) => {
  try {
    const admins = await User.find({});
    res.status(200).json(admins);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error fetching admins' });
  }
};

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
    const { name, class: classNum, phone, school } = req.body;
    
    // 1. Validate inputs
    if (!name || !classNum || !phone || !school) {
      return res.status(400).json({ 
        success: false,
        message: "All fields are required" 
      });
    }

    // 2. Find admin by name (not using JWT token, relying on frontend validation)
    const { adminNumber } = req.body;

const admin = await User.findOne({ number: adminNumber });
if (!admin) {
  return res.status(404).json({ 
    success: false,
    message: "Admin not found" 
  });
}

    // 3. ✅ Handle both formats: string or array
    const assignedSchoolList = typeof admin.assignedSchoolList === 'string'
      ? admin.assignedSchoolList.split(',').map(s => s.trim())
      : Array.isArray(admin.assignedSchoolList) 
        ? admin.assignedSchoolList 
        : [];

    // 4. Validate school assignment
    const isAssigned = assignedSchoolList.includes(school);
    if (!isAssigned) {
      return res.status(403).json({
        success: false,
        message: "Not authorized for this school"
      });
    }

    // 5. Create teacher
    const teacher = new Teacher({
      name,
      class: parseInt(classNum),
      phone,
      school_name: school
    });

    await teacher.save();

    // 6. Update school's teachers array
    const schoolDoc = await School.findOne({ schoolName: school });
    if (!schoolDoc) {
      return res.status(404).json({ 
        success: false,
        message: "School not found" 
      });
    }

    schoolDoc.teachers.push(teacher._id);
    await schoolDoc.save();

    // 7. ✅ Success response
    res.status(200).json({
      success: true,
      message: "Teacher Account Created",
      teacher
    });

  } catch (error) {
    console.error(`Error creating teacher: ${error.message}`);
    res.status(500).json({ 
      success: false,
      message: "Error Creating Teacher Account",
      error: error.message
    });
  }
};

const getAssignedSchoolsForAdmin = async (req, res) => {
  const { phoneNumber } = req.query;

  if (!phoneNumber) {
    return res.status(400).json({ success: false, error: "Phone number is required" });
  }

  try {
    const admin = await User.findOne({ number: phoneNumber });

    if (!admin) {
      return res.status(404).json({ success: false, error: "Admin not found" });
    }

    // ✅ Query schools where admin._id is in School.assignedAdmins
    const assignedSchools = await School.find(
      { assignedAdmins: admin._id },
      { schoolName: 1 }
    );

    if (!assignedSchools || assignedSchools.length === 0) {
      return res.status(200).json({
        success: true,
        data: [],
        message: "No schools assigned to this admin",
      });
    }

    res.status(200).json({
      success: true,
      data: assignedSchools.map(s => s.schoolName),
      message: "Assigned schools fetched successfully",
    });

  } catch (error) {
    console.error(`Error fetching assigned schools for admin: ${error.message}`);
    res.status(500).json({ success: false, error: "Server error" });
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

    // 1. Basic validation
    if (!name || !age || !schoolID) {
      return res.status(400).json({
        success: false,
        message: "Name, Age, and School ID are required"
      });
    }

    
    // 2. Find admin by name (from frontend)
    const { adminNumber } = req.body;

const admin = await User.findOne({ number: adminNumber });
if (!admin) {
  return res.status(404).json({ 
    success: false,
    message: "Admin not found" 
  });
}

    // 3. ✅ Handle string or array format
    const assignedSchoolList = Array.isArray(admin.assignedSchoolList)
  ? admin.assignedSchoolList
  : typeof admin.assignedSchoolList === 'string'
    ? admin.assignedSchoolList.split(',').map(s => s.trim())
    : [];

const isAuthorized = assignedSchoolList.includes(req.body.schoolID || req.body.school);

if (!isAuthorized) {
  return res.status(403).json({ message: "Not authorized for this school" });
}

    // 4. Validate school assignment
    const isAssigned = assignedSchoolList.includes(schoolID);
    if (!isAssigned) {
      return res.status(403).json({
        success: false,
        message: "Not authorized for this school"
      });
    }
    const school = await School.findOne({ schoolName: schoolID }).select('_id');
if (!school) {
  return res.status(404).json({
    success: false,
    message: "School not found"
  });
}


    // 5. Create child document
    const child = new Child({
      name,
      rollNumber,
      schoolID: school._id,
      parentName,
      parentPhoneNumber: parseInt(parentPhoneNumber), // Convert to number
      class: classNum ? parseInt(classNum) : undefined,
      age: parseInt(age)
    });

    await child.save();

    // 6. ✅ Success response
    await child.save();

res.status(201).json({
  success: true,
  message: "Child added successfully",
  child: {
    ...child.toObject(),
    schoolName: school.schoolName
  }
});

  } catch (error) {
    console.error(`Error adding child: ${error.message}`);
    res.status(500).json({
      success: false,
      message: "Error adding child",
      error: error.message
    });
  }
};


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
            children = await Child.find({ parentPhoneNumber: phone })
        .populate('schoolID', 'schoolName');
        } else if (role === "Teacher") {
            // Fetch all children for teachers
            children = await Child.find()
        .populate('schoolID', 'schoolName');
        } else {
            return res.status(400).json({ message: "Invalid role" });
        }
        const formattedChildren = children.map(child => {
          const school = child.schoolID || {};
          return {
            _id: child._id,
            name: child.name,
            age: child.age,
            rollNumber: child.rollNumber,
            parentName: child.parentName,
            parentPhoneNumber: child.parentPhoneNumber,
            class: child.class,
            schoolId: child.schoolID?._id?.toString() || '', // MongoDB ObjectId
            schoolName: school.schoolName || '' // Human-readable name
          };
        });
    
        res.status(200).json(formattedChildren);
    } catch (error) {
        console.error("Error fetching children:", error);
        res.status(500).json({ message: "Error fetching children" });
    }
};
const verifyProfessional = async (req, res) => {
  try {
    const { professionalId } = req.query;
    console.log('Verifying professional:', professionalId);

    const professional = await Professional.findOne({ Number: professionalId });
    if (!professional) {
      return res.status(404).json({ 
        found: false,
        message: 'Professional not found' 
      });
    }

    // Get school names for assigned schools
    const schools = await School.find({
      _id: { $in: professional.assignedSchools }
    });

    const schoolInfo = schools.map(school => ({
      id: school._id,
      name: school.schoolName
    }));

    res.json({
      found: true,
      professional: {
        name: professional.name,
        phone: professional.Number,
        assignedSchools: schoolInfo
      }
    });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: error.message });
  }
};

const storeReportData = async (req, res) => {
  try {
    console.log("Request Body:", req.body); // Log incoming request data

    const data = req.body;

    // Parse submittedBy from JSON string
    let submittedBy = {};
    try {
      submittedBy = data.submittedBy ? JSON.parse(data.submittedBy) : {};
    } catch (e) {
      return res.status(400).json({ error: "Invalid submittedBy format" });
    }

    if (submittedBy.id && !submittedBy.phone) {
      submittedBy.phone = submittedBy.id;
    }
    
    if (!submittedBy || !submittedBy.role || !submittedBy.phone) {
      console.error("User information is missing or invalid.");
      return res.status(400).json({ error: "User information is missing or invalid." });
    }
    

    console.log("Submitted By:", submittedBy); // Log submittedBy object

    // Parse nested objects (houseAns, personAns, treeAns)
   
    try {
      // Parse answers (expect JSON strings from frontend)
      const houseAnswers = req.body.houseAns ? JSON.parse(req.body.houseAns) : {};
      const treeAnswers = req.body.treeAns ? JSON.parse(req.body.treeAns) : {};
      const personAnswers = req.body.personAns ? JSON.parse(req.body.personAns) : {};
  
      console.log("🔍 Raw request body fields:", Object.keys(req.body));
      console.log("🔍 houseAns field:", req.body.houseAns);
      console.log("🔍 personAns field:", req.body.personAns);
      console.log("🔍 treeAns field:", req.body.treeAns);
      console.log("🔍 Parsed houseAnswers:", houseAnswers);
      console.log("🔍 HOUSE_QUESTIONS expected:", HOUSE_QUESTIONS);
  
      // Validate answers against fixed questions
      const validateAnswers = (answers, questions) => {
        const isValid = questions.every(q => answers.hasOwnProperty(q) && answers[q] != null);
        console.log(`🔍 Validation for ${questions.length} questions:`, isValid);
        questions.forEach(q => {
          console.log(`  - ${q}: ${answers.hasOwnProperty(q) ? '✅' : '❌'} (value: ${answers[q]})`);
        });
        return isValid;
      };
  
      if (!validateAnswers(houseAnswers, HOUSE_QUESTIONS)) {
        return res.status(400).json({ error: 'Invalid or missing house answers' });
      }
      if (!validateAnswers(treeAnswers, TREE_QUESTIONS)) {
        return res.status(400).json({ error: 'Invalid or missing tree answers' });
      }
      if (!validateAnswers(personAnswers, PERSON_QUESTIONS)) {
        return res.status(400).json({ error: 'Invalid or missing person answers' });
      }

    console.log("House Answers:", houseAnswers); // Log grouped answers
    console.log("Person Answers:", personAnswers);
    console.log("Tree Answers:", treeAnswers);

    // Validate required fields in nested objects
    const requiredFields = [
      "Who_Lives_Here",
      "Are_there_Happy",
      "Do_People_Visit_Here",
      "What_else_people_want",
      "Who_is_this_person",
      "How_old_are_they",
      "Whats_thier_fav_thing",
      "What_they_dont_like",
      "What_kind_of_tree",
      "how_old_is_it",
      "what_season_is_it",
      "anyone_tried_to_cut",
      "what_else_grows",
      "who_waters",
      "does_it_get_enough_sunshine",
    ];


    const missingFields = requiredFields.filter(
      (field) => !(houseAnswers[field] || personAnswers[field] || treeAnswers[field])
    );
    if (missingFields.length > 0) {
      console.error("Missing Fields:", missingFields);
      return res.status(400).json({
        error: "The following fields are missing:",
        missingFields,
      });
    }

    // Extract role-specific fields
    let clinicName = "";

    let childsName = "";
    let age = null;
    let optionalNotes = "";
    let flagforlabel = false; // Default to false
    let labelling = "";

    // Populate role-specific fields only for Professionals
    if (submittedBy.role === "Professional") {
      clinicName = Professional.clinicName;
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
    const { schoolId } = data;
    let schoolName = '';
if (schoolId) {
  const school = await School.findById(schoolId).select('schoolName');
  if (school) {
    schoolName = school.schoolName;
  }
}
    // Create the report object
    const report = new Report({
      clinicName,
      childsName,
      age,
      schoolId,
      schoolName, 
      optionalNotes,
      flagforlabel,
      labelling,
      images: {
        house: {
          path: req.files.houseImage?.[0]?.path || null,
          score: 0,
          manualScore: null,
          labeledBy: null,
          labeledAt: null
        },
        tree: {
          path: req.files.treeImage?.[0]?.path || null,
          score: 0,
          manualScore: null,
          labeledBy: null,
          labeledAt: null
        },
        person: {
          path: req.files.personImage?.[0]?.path || null,
          score: 0,
          manualScore: null,
          labeledBy: null,
          labeledAt: null
        }
      },
      houseAns: houseAnswers,
      treeAns: treeAnswers,
      personAns: personAnswers,
      submittedBy: {
        role: submittedBy.role,
        phone: submittedBy.phone,
       
      },
      childId: req.body.childId || null, // Set from frontend for parent/teacher, null for professional
    });

    console.log("Report Object:", report); // Log the report object

    // Save the report
    await report.save();
    console.log("Report Saved Successfully"); // Log successful save
    console.log("📢 Incoming report data:", JSON.stringify(data, null, 2));
    console.log("📎 Submitted by:", data.submittedBy);
    console.log("📌 Child name:", data.childsName);
    console.log("🏫 schoolId:", data.schoolId); // This may be null
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
    } catch (error) {
    console.error("Error in storeReportData:", error);
    res.status(500).json({ error: "An error occurred while storing report data." });
  }
};


const editUserProfile = async (req, res) => {
  const { role, phone } = req.body;
  const updateData = req.body;

  try {
    let user;
    switch (role) {
      case 'Parent':
        // Parents are stored in Child model under parentPhoneNumber
        user = await Child.findOne({ parentPhoneNumber: parseInt(phone) });
        break;
      case 'Teacher':
        user = await Teacher.findOne({ phone: phone });
        break;
      case 'Professional':
        user = await Professional.findOne({ Number: phone });
        break;
      case 'SchoolAdmin':
      case 'NGOAdmin':
        user = await User.findOne({ number: phone });
        break;
      default:
        return res.status(400).json({ message: "Unsupported role" });
    }

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Update fields dynamically (skip immutable ones)
    Object.keys(updateData).forEach(key => {
      if (['role', 'phone', 'number'].includes(key)) return; // skip these
      if (updateData[key] !== null && updateData[key] !== '') {
        user[key] = updateData[key];
      }
    });

    await user.save();

    // Return updated user
    res.json({
      success: true,
      message: "Profile updated successfully",
      updatedUser: user
    });

  } catch (error) {
    console.error("Error updating profile:", error);
    res.status(500).json({ success: false, message: "Server error", error: error.message });
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

    // Fetch submissions
    const submissions = await Report.find(query).populate('schoolId', 'schoolName');

    // Optional: Fetch child details too
    const child = await Child.findOne({ name: childsName });

    // ✅ Now we can log child info
    console.log("📚 Child Data:", JSON.stringify({
      name: child?.name,
      age: child?.age,
      schoolID: child?.schoolID
    }, null, 2));

    // ✅ Log submission data
    console.log("📚 Submissions Fetched:", JSON.stringify(submissions.map(s => ({
      childsName: s.childsName,
      age: s.age,
      schoolId: s.schoolId,
      submittedAt: s.submittedAt
    })), null, 2));

    return res.status(200).json(submissions);

  } catch (error) {
    console.error("Error fetching submissions by child:", error);
    return res.status(500).json({ error: "Error fetching submissions by child" });
  }
};



// Inside users.controller.js

const searchNumber = async (req, res) => {
  console.log("📢 Request received at /api/users/search-number");
  const data = req.body;
  try {
    // --- MODIFICATION START ---
    // Check if this is a request to find the user in ANY role
    const isAnyRoleRequest = data.usertype === "Any" || data.usertype === undefined || data.usertype === null;
    const number = data.number;

    if (!number) {
       return res.status(400).json({ message: "Phone number is required." });
    }

    // --- Handle "Any Role" Request ---
    if (isAnyRoleRequest) {
      console.log(`🔍 Searching for user with number ${number} in ANY role.`);

      // 1. Check Unified User Model (Admins)
      let user = await User.findOne({ number: number });
      if (user) {
        console.log(`✅ Found user in User model (Admin): ${user.role}`);
        const frontendRoleMap = {
          'NGOAdmin': 'NGO Master',
          'SchoolAdmin': 'Admin'
        };
        const frontendRole = frontendRoleMap[user.role] || user.role;
        return res.status(200).json({
          success: true,
          exists: true,
          message: `User found as ${frontendRole}`,
          // Optionally include minimal profile data if needed immediately
          // detectedRole: frontendRole,
          // name: user.name
        });
      }

      // 2. Check Professional Model
      user = await Professional.findOne({ Number: number });
      if (user) {
        console.log("✅ Found user in Professional model");
        return res.status(200).json({
          success: true,
          exists: true,
          message: "User found as Professional",
          // detectedRole: "Professional",
          // name: user.name,
          // clinicName: user.clinicName
        });
      }

      // 3. Check Teacher Model
      user = await Teacher.findOne({ phone: number });
      if (user) {
        console.log("✅ Found user in Teacher model");
        return res.status(200).json({
          success: true,
          exists: true,
          message: "User found as Teacher",
          // detectedRole: "Teacher",
          // name: user.name
        });
      }

      // 4. Check Child Model (for Parent)
      // Ensure phone number is treated as a number for comparison if stored as Number in DB
      const phoneNumberInt = parseInt(number, 10);
      if (!isNaN(phoneNumberInt)) {
         user = await Child.findOne({ parentPhoneNumber: phoneNumberInt });
         if (user) {
           console.log("✅ Found user in Child model (Parent)");
           return res.status(200).json({
             success: true,
             exists: true,
             message: "User found as Parent",
             // detectedRole: "Parent",
             // name: user.parentName
           });
         }
      }

      // 5. If no user found in any collection
      console.log(`❓ User not found in any model for number: ${number}`);
      return res.status(404).json({
        success: false,
        exists: false, // Explicitly state user doesn't exist
        message: `User not found for phone number ${number} in any role.`
      });
    }
    // --- MODIFICATION END (for "Any" role) ---

    // --- ORIGINAL LOGIC (for specific role) ---
    // If usertype is provided and not "Any", proceed with original logic
    const usertype = data.usertype;
    // Unified User Model Roles
    const roleMap = {
      "NGO Master": "NGOAdmin",
      "School Admin": "SchoolAdmin",
      "Admin": "SchoolAdmin"
    };

    const role = roleMap[usertype];
    if (role) {
      // ✅ Query unified User model
      const user = await User.findOne({ number: number, role: role });
      if (!user) {
        return res.status(404).json({ message: `${usertype} Not Found` });
      }
      // ✅ Return standardized response
      return res.status(200).json({
        name: user.name,
        number: user.number,
        role: user.role,
        assignedSchoolList: user.assignedSchoolList || []
      });
    }

    // Legacy Models
    if (usertype == "Teacher") {
      const teacher = await Teacher.findOne({ phone: number });
      if (!teacher) {
        return res.status(404).json({ message: "Teacher Not Found" });
      }
      return res.status(200).json({
        name: teacher.name,
        number: teacher.phone,
        role: "Teacher",
        school_name: teacher.school_name
      });
    }
    if (usertype == "Professional") {
      const professional = await Professional.findOne({ Number: number });
      if (!professional) {
        return res.status(404).json({ message: "Professional Not Found" });
      }
      return res.status(200).json({
        name: professional.name,
        number: professional.Number,
        role: "Professional",
        clinicName: professional.clinicName,
        assignedSchools: professional.assignedSchools
      });
    }
    if (usertype == "Parent") {
      const parent = await Child.findOne({ parentPhoneNumber: number }); // Note: might need parseInt(number) if stored as Number
      if (!parent) {
        return res.status(404).json({ message: "Parent Not Found" });
      }
      return res.status(200).json({
        name: parent.parentName,
        number: parent.parentPhoneNumber,
        role: "Parent",
        childName: parent.name,
        childAge: parent.age
      });
    }

    // Invalid usertype
    return res.status(400).json({ message: "Invalid usertype or 'usertype' not provided for specific lookup." });
  } catch (error) {
    console.error(`Error fetching user: ${error.message}`);
    return res.status(500).json({ message: "Internal Server Error" });
  }
};

// Make sure 'searchNumber' is still exported correctly
// export { ..., searchNumber, ... };

const getProfessionalProfile = async (req, res) => {
  const { phone } = req.query;
  if (!phone) return res.status(400).json({ error: "Phone is required" });
  const professional = await Professional.findOne({ Number: phone });
  if (!professional) return res.status(404).json({ error: "Not found" });
  res.json({
    name: professional.name,
    number: professional.Number,
    clinicName: professional.clinicName,
    // ...any other fields you want
  });
};
// Inside users.controller.js

// --- NEW FUNCTION: Detect Role and Fetch Profile ---
const detectRoleAndFetchProfile = async (req, res) => {
  console.log("📢 Request received at /api/users/detect-role-and-fetch-profile");
  // Expect phone number in request body (standard for POST)
  const { phoneNumber } = req.body;

  if (!phoneNumber) {
    console.log("❌ Phone number is missing from request body");
    return res.status(400).json({ success: false, message: "Phone number is required in request body" });
  }

  try {
    let user = null;
    let detectedRole = null;
    let profileData = {}; // Object to hold role-specific data

    console.log(`🔍 Searching for user with phone number: ${phoneNumber}`);

    // 1. Check Unified User Model (Admins: NGOAdmin, SchoolAdmin)
    // Use lean() for better performance as we don't need Mongoose document methods
    user = await User.findOne({ number: phoneNumber }).lean();
    if (user) {
      console.log(`✅ Found user in User model with role: ${user.role}`);
      // Map internal backend roles to consistent frontend roles
      // Make sure these frontend role names match what your Flutter app expects
      const frontendRoleMap = {
        'NGOAdmin': 'NGO Master',     // Map internal 'NGOAdmin' to frontend 'NGO Master'
        'SchoolAdmin': 'Admin'        // Map internal 'SchoolAdmin' to frontend 'Admin'
      };
      detectedRole = frontendRoleMap[user.role] || user.role; // Default to internal role if no mapping

      profileData = {
        name: user.name,
        number: user.number,
        // Normalize assignedSchoolList to ensure it's always an array of strings
        // The getAdmins controller shows normalization logic
        assignedSchoolList: Array.isArray(user.assignedSchoolList)
          ? user.assignedSchoolList.filter(s => s && typeof s === 'string') // Ensure strings
          : (typeof user.assignedSchoolList === 'string'
             ? user.assignedSchoolList.split(',').map(s => s.trim()).filter(Boolean)
             : [])
      };
      console.log(`📤 Sending response for Admin role: ${detectedRole}`);
      return res.status(200).json({
        success: true,
        detectedRole: detectedRole,
        profileData: profileData,
        message: `User found with role: ${detectedRole}`
      });
    }

    // 2. Check Professional Model
    // Use lean() for better performance
    user = await Professional.findOne({ Number: phoneNumber }).lean();
    if (user) {
      console.log("✅ Found user in Professional model");
      detectedRole = "Professional";
      profileData = {
        name: user.name,
        number: user.Number,
        clinicName: user.clinicName,
        // assignedSchools are ObjectIds. Send them as strings.
        // The frontend or another endpoint can fetch names if needed immediately.
        assignedSchoolIds: user.assignedSchools ? user.assignedSchools.map(id => id.toString()) : []
      };
      console.log("📤 Sending response for Professional role");
      return res.status(200).json({
        success: true,
        detectedRole: detectedRole,
        profileData: profileData,
        message: "User found with role: Professional"
      });
    }

    // 3. Check Teacher Model
    // Use lean() for better performance
    user = await Teacher.findOne({ phone: phoneNumber }).lean();
    if (user) {
      console.log("✅ Found user in Teacher model");
      detectedRole = "Teacher";
      profileData = {
        name: user.name,
        number: user.phone,
        school_name: user.school_name, // Teacher model uses school_name (String)
        class: user.class
      };
      console.log("📤 Sending response for Teacher role");
      return res.status(200).json({
        success: true,
        detectedRole: detectedRole,
        profileData: profileData,
        message: "User found with role: Teacher"
      });
    }

    // 4. Check Child Model (for Parent)
    // Note: Assumes parentPhoneNumber is unique to one parent.
    // If a parent has multiple children, this finds the first child record.
    // Use lean() for better performance
    // Ensure phone number is treated as a number for comparison if stored as Number in DB
    const phoneNumberInt = parseInt(phoneNumber, 10);
    if (isNaN(phoneNumberInt)) {
         console.log("⚠️ Provided phone number is not a valid integer for Parent lookup");
         // Continue to not found case
    } else {
         user = await Child.findOne({ parentPhoneNumber: phoneNumberInt }).lean();
         if (user) {
           console.log("✅ Found user in Child model (Parent)");
           detectedRole = "Parent";
           profileData = {
             name: user.parentName,
             number: user.parentPhoneNumber.toString(), // Ensure it's a string
             // Potentially include child info if needed immediately
             // childName: user.name,
             // childAge: user.age
           };
           console.log("📤 Sending response for Parent role");
           return res.status(200).json({
             success: true,
             detectedRole: detectedRole,
             profileData: profileData,
             message: "User found with role: Parent"
           });
         }
    }


    // 5. If no user found in any collection
    console.log(`❓ User not found in any model for number: ${phoneNumber}`);
    return res.status(404).json({ success: false, message: `User not found for phone number ${phoneNumber} in any role.` });

  } catch (error) {
    console.error("💥 Error in detectRoleAndFetchProfile:", error.message);
    // Log stack trace for debugging
    console.error(error.stack);
    return res.status(500).json({ success: false, message: "Internal Server Error during role detection" });
  }
};
// --- END NEW FUNCTION ---


export default responder;
export { createProfessionalAccount,
    getProfessionalIds, 
    createSchoolAccount, 
    detectRoleAndFetchProfile,
    // createNgoAdminAccount,
     assignAdminToSchool,
    getAdmins,
    createAdmin,
  
    getAllAdmins,
    getSchools,
    storeReportData,
    verifyProfessional,
    uploadteacherdetails,
    getAllTeachers,
    getchilddetails,
    uploadchilddetails,
    getSubmissionsByChild,
    getsubmissionsummary ,
    getAssignedSchoolsForAdmin ,
    getAssignedSchoolsForProfessional,
    assignSchoolToProfessional,
    searchNumber,
    getSchoolAdmins,
    editUserProfile,
    getProfessionalProfile,

};