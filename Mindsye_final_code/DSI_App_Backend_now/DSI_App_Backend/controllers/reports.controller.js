import {Report} from '../models/report.model.js';

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
    getOneClinicReport
 };