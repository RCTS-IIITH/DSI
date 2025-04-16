import {Report} from '../models/report.model.js';
import Submission from '../models/submissionmodel.js';
import { Child } from '../models/child.model.js';

const testing = (req, res) => {
    res.status(200).json({ message: "Hello World" });
}

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
const getOneClinicReport = async (req, res) => {
    const id = req.params.id;
    try {
        const report = await Report.findById(id);
        res.status(200).json(report);
    }
    catch (error) {
        console.log(error);
        res.status(500).json({ message: "Error Fetching Report" });
    }
}

export { testing,
    getReportDataClinic,
    getOneClinicReport,getSubmissions,
 };