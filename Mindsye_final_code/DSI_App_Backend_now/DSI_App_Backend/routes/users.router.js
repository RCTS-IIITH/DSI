import { Router } from "express";

import { createProfessionalAccount, 
    getProfessionalIds, 
    createSchoolAccount, 
    createNgoAdminAccount,
    assignAdminToSchool,
    getAdmins,
    getSchools,
    getchilddetails,
    uploadteacherdetails,
    uploadchilddetails,
    searchNumber,
    getSchoolAdmins,
  createSchoolAdmin,
  getSubmissionsByChild,
  getAssignedSchoolsForProfessional,
    assignSchoolToProfessional,
    getsubmissionsummary ,
    
    getAllTeachers,
} from "../controllers/users.controller.js";



const router = Router();
// router.route("/testing").post(responder);
router.route("/create-professional").post(createProfessionalAccount);
router.route("/getProfessionalIds").get(getProfessionalIds);
router.route("/create-school").post(createSchoolAccount);
router.route("/create-ngo-admin").post(createNgoAdminAccount);
router.route("/assign-admin-to-school").post(assignAdminToSchool);
router.route("/get-admins").get(getAdmins);
router.route("/get-schools").get(getSchools);
router.route('/getteachers').get(getAllTeachers)
router.route("/teacherupload").post(uploadteacherdetails);
router.route("/childupload").post(uploadchilddetails);
router.route("/search-number").post(searchNumber);
router.route("/get-school-admins").get(getSchoolAdmins);
router.route("/create-school-admin").post(createSchoolAdmin);
router.route("/getchildren").get(getchilddetails);
router.route('/get-submissions-by-child').get(getSubmissionsByChild);
router.route('/get-submission-summary').get(getsubmissionsummary);
router.route("/assign-school-to-professional").post(assignSchoolToProfessional);
router.route("/get-assigned-schools").get(getAssignedSchoolsForProfessional);

export default router;
