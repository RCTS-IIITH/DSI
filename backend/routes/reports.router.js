import { Router } from "express";
import { storeReportData,
 } from "../controllers/users.controller.js";


 import { testing ,

    getReportDataClinic,
    getOneClinicReport,getProfessionalReports,  getParentSubmissions, getNgoSubmissions, getSchoolSubmissions
 } from "../controllers/reports.controller.js";
const router = Router();
router.route("/store-report-data").post(storeReportData);
router.route("/get-report-data-clinic").get(getReportDataClinic);
router.route("/get-report-data-clinic/:id").get(getOneClinicReport);
router.route("/get-professional-reports").get(getProfessionalReports);
router.route("/testing").get(testing);
router.route("/get-parent-submissions").get(getParentSubmissions);
router.route("/get-ngo-submissions").get(getNgoSubmissions);
router.route("/get-school-submissions").get(getSchoolSubmissions);


export default router;