import { Router } from "express";
import { storeReportData,
 } from "../controllers/users.controller.js";


 import { testing ,
   getSubmissions,
    getReportDataClinic,
    getOneClinicReport
 } from "../controllers/reports.controller.js";
const router = Router();
router.route("/store-report-data").post(storeReportData);
router.route("/get-report-data-clinic").get(getReportDataClinic);
router.route("/get-report-data-clinic/:id").get(getOneClinicReport);
router.route("/testing").get(testing);
router.route("/get-submissions").get(getSubmissions);

export default router;