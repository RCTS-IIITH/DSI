import { Router } from "express";
import { storeReportData,
 } from "../controllers/users.controller.js";


 import { testing ,

    getReportDataClinic,
    getOneClinicReport,getProfessionalReports,  getParentSubmissions, getNgoSubmissions, getSchoolSubmissions, getProfessionalSchoolSubmissions, getTeacherSubmissions
 } from "../controllers/reports.controller.js";
import { upload } from '../middleware/upload.js';
const router = Router();
router.post('/store-report-data', upload.single('image'), storeReportData);
router.route("/get-report-data-clinic").get(getReportDataClinic);
router.route("/get-report-data-clinic/:id").get(getOneClinicReport);
router.route("/get-professional-reports").get(getProfessionalReports);
router.route("/testing").get(testing);
router.route("/get-parent-submissions").get(getParentSubmissions);
router.route("/get-ngo-submissions").get(getNgoSubmissions);
router.route("/get-school-submissions").get(getSchoolSubmissions);
router.route("/professional-school-submissions").get(getProfessionalSchoolSubmissions);
router.get('/get-teacher-submissions', getTeacherSubmissions);


export default router;