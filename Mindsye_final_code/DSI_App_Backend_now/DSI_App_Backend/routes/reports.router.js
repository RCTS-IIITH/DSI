import { Router } from "express";
import { storeReportData,
 } from "../controllers/users.controller.js";


 import { testing ,
    getReportDataClinic,
    getOneClinicReport
 } from "../controllers/reports.controller.js";
const router = Router();
router.route("/store-report-data").post(storeReportData);
router.route("/get-report-data-clinic").get(getReportDataClinic);
router.route("/get-report-data-clinic/:id").get(getOneClinicReport);
router.route("/testing").get(testing);

export default router;