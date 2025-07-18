import {Report} from '../models/report.model.js';
import mongoose from 'mongoose';
import {Professional} from '../models/professional.model.js'; 
import {School} from '../models/school.model.js';
import {User} from '../models/user.model.js'; // Import User model for NGO admin lookups
const testing = (req, res) => {
    res.status(200).json({ message: "Hello World" });
}
import { Types } from 'mongoose';
const { ObjectId } = Types;


const getProfessionalReports = async (req, res) => {
  try {
    const { professionalId } = req.query;
    console.log('Fetching reports for professional:', professionalId);

    // Get professional's assigned schools
    const professional = await Professional.findOne({ Number: professionalId });
    if (!professional) {
      return res.status(404).json({ message: 'Professional not found' });
    }

    // Get school names for assigned schools
    // Get school documents for assigned schools
const assignedSchools = await School.find({
  _id: { $in: professional.assignedSchools }
});

// Extract just the ObjectId strings
const assignedSchoolIds = assignedSchools.map(s => s._id.toString());
    // Fetch reports from assigned schools or submitted by this professional
    const reports = await Report.find({
  $or: [
    { 'submittedBy.phone': professionalId }, // ✅ Reports submitted by this pro
    { schoolId: { 
      $in: assignedSchoolIds.map(id => new ObjectId(id)) 
    }} // ✅ From assigned schools
  ]
}).populate('schoolId', 'schoolName'); 

res.json(
  reports.map(report => ({
    ...report.toObject(),
    schoolName: report.schoolId?.schoolName || 'Unknown School',
  }))
);
  } catch (error) {
    console.error('Error in getProfessionalReports:', error);
    res.status(500).json({ error: error.message });
  }
};


const getReportDataClinic = async (req, res) => {
    try {
        const reports = await Report.find({});
        res.status(200).json(reports);
    }
    catch (error) {
        console.log(error);
        res.status(500).json({ message: "Error Fetching Reports" });
    }
}
const getParentSubmissions = async (req, res) => {
  try {
    const { parentPhone, date } = req.query;
    
    // Convert ISO date string to Date object range
    const startDate = new Date(date);
    const endDate = new Date(date);
    endDate.setDate(endDate.getDate() + 1);

    const count = await Report.countDocuments({
      'submittedBy.phone': parentPhone,
      submittedAt: {
        $gte: startDate,
        $lt: endDate
      }
    });

    res.json({ count });
  } catch (error) {
    console.error('Error in getParentSubmissions:', error);
    res.status(500).json({ error: error.message });
  }
};


const getOneClinicReport = async (req, res) => {
    const { id } = req.params;
  
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ message: 'Invalid report ID' });
    }
  
    try {
      const report = await Report.findById(id);
  
      if (!report) {
        return res.status(404).json({ message: 'Report not found' });
      }
  
      res.status(200).json(report);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Error fetching report' });
    }
  };
  const getNgoSubmissions = async (req, res) => {
    try {
      const { ngoAdminPhone, date } = req.query;
      
      // Convert ISO date string to Date object range
      const startDate = new Date(date);
      const endDate = new Date(date);
      endDate.setDate(endDate.getDate() + 1);
  
      // Update the role check to match "NGOAdmin" instead of "NGO Master"
      const ngoAdmin = await User.findOne({ 
        number: ngoAdminPhone, 
        role: "NGOAdmin"  // Changed from "NGO Master" to "NGOAdmin"
      });
  
      if (!ngoAdmin) {
        return res.status(404).json({ 
          error: 'NGO admin not found',
          details: `No NGO admin found with phone: ${ngoAdminPhone}`
        });
      }
  
      // Get all school IDs assigned to this NGO admin
      const assignedSchoolIds = ngoAdmin.assignedSchoolList || [];
  
      // Convert school names to ObjectIds if they're not already
      const schoolIds = await Promise.all(assignedSchoolIds.map(async (schoolId) => {
        if (mongoose.Types.ObjectId.isValid(schoolId)) {
          return new ObjectId(schoolId);
        }
        // If it's a school name, find its ID
        const school = await School.findOne({ schoolName: schoolId });
        return school ? school._id : null;
      }));
  
      // Filter out null values
      const validSchoolIds = schoolIds.filter(id => id !== null);
  
      // Get today's submissions count
      const todayCount = await Report.countDocuments({
        schoolId: { $in: validSchoolIds },
        submittedAt: {
          $gte: startDate,
          $lt: endDate
        }
      });
  
      // Get total submissions count
      const totalCount = await Report.countDocuments({
        schoolId: { $in: validSchoolIds }
      });
  
      res.json({ 
        todayCount, 
        totalCount,
        date: startDate,
        ngoAdmin: ngoAdminPhone,
        schoolCount: validSchoolIds.length
      });
  
    } catch (error) {
      console.error('Error in getNgoSubmissions:', error);
      res.status(500).json({ error: error.message });
    }
  };
  

const getSchoolSubmissions = async (req, res) => {
  try {
    const { schoolId, date } = req.query;
    if (!schoolId || !date) {
      return res.status(400).json({ error: "schoolId and date are required" });
    }
    const startDate = new Date(date);
    const endDate = new Date(date);
    endDate.setDate(endDate.getDate() + 1);

    const count = await Report.countDocuments({
      schoolId: schoolId,
      submittedAt: {
        $gte: startDate,
        $lt: endDate
      }
    });

    res.json({ count });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};


export { testing,
    getReportDataClinic,
    getOneClinicReport,
    getProfessionalReports ,
    getParentSubmissions,
    getNgoSubmissions,
    getSchoolSubmissions
 };