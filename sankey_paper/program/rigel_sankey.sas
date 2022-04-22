
libname inds "/u02/home/tkhole/sankey_paper/input_data" ;
filename infl "/u02/home/tkhole/sankey_paper/input_data" ;

libname outds "/u02/home/tkhole/sankey_paper/output_data" ;
filename outg "/u02/home/tkhole/sankey_paper/output_html";




options validvarname=V7;
options validvarname=upcase;

%macro get_ds(fl=, outds=);
proc import datafile="%sysfunc(pathname(infl,f))/&fl..csv"
     out=&outds.(where=(study_type="Interventional" /*phases not in ( ' ' 'Not Applicable') and Interventions ne ' ' and status in ("Active, not recruiting" 
      "Available"  
      "Enrolling by invitation"  
      "Not yet recruiting"
      "Recruiting")*/ ))
     dbms=csv
     replace;
     getnames=yes;
	 guessingrows=32767;
run;
%mend get_ds;

%get_ds(fl=rigel, outds=rigl_ct);



/**********STEP 1 - Data Analysis*************/
data rigl_ct_;
	set rigl_ct(in=a) ;

	  if substr(strip(upcase(compress(sponsor_collaborators))), 1, 20) = "RIGELPHARMACEUTICALS" ;

	  SPNSR="RIGEL";

	  *if phases in ("Early Phase 1" "Phase 1") then delete;

	  if phases = "Phase 1|Phase 2" then phases = "Phase 2";
	  if phases = "Phase 2|Phase 3" then phases = "Phase 3";
	  phases = upcase(phases);
run;



proc freq data=rigl_ct_ noprint ;
	table Status / list missing out= rigl_status;
	table Study_Results / list missing ;
	table Conditions / list missing out=rigl_cond;
	table Interventions / list missing out=rigl_int;
	table Outcome_Measures / list missing out=rigl_out_meas;
	table Phases / list missing out=rigl_phases;
	table SPNSR / list missing out=spnsr_wt;
	table SPNSR*Status*Interventions*Conditions*Phases / list missing out=rigl_wt;

run;



data rigl_ct_da0;
	set rigl_ct_;

	/*Conditions*/
	%let MM_cond=%str((index(upcase(conditions), "MULTIPLE MYELOMA") > 0 or index(upcase(conditions), "MYELOMA") > 0));

	%let mds_cond = %str(index(upcase(conditions), "MYELODYSPLASTIC SYNDROMES") > 0 or index(upcase(conditions), "MDS") > 0 or 
						 index(upcase(conditions), "MYELODYSPLASTIC") > 0);

	%let aml_cond = %str(index(upcase(conditions), "AML") > 0 or index(upcase(conditions), "MYELOID") > 0 or 
						 index(upcase(conditions), "MYELOGENOUS") > 0);

	%let lym_cond = %str(index(upcase(conditions), "LYMPHOMA") > 0 or index(upcase(conditions), "HODGKIN") > 0 or
						 index(upcase(conditions), "WALDENSTROM'S MACROGLOBULINEMIA") > 0 or index(upcase(conditions), "WALDENSTROM MACROGLOBULINEMIA") > 0
						 );

	%let cc_cond = %str(index(upcase(conditions), "CHRONIC LYMPHOCYTIC LEUKEMIA") > 0 or index(upcase(conditions), " LYMPHOCYTIC LEUKEMIA") > 0 or 
						index(upcase(conditions), " LYMPHOCYTIC") > 0 );

	%let leuk_cond = %str(index(upcase(conditions), "LEUKEMIA") > 0 );
 

	%let bd_cond = %str(index(upcase(conditions), "BETA-THALASSEMIA") > 0 or index(upcase(conditions), "THALASSEMIA") > 0 or
						index(upcase(conditions), "HEMOPHILIA") > 0
						);

	%let mf_cond = %str(index(upcase(conditions), "MYELOFIBROSIS") > 0 or index(upcase(conditions), "MF") > 0 );

	%let st_cond = %str( index(upcase(conditions), "SOLID TUMOR") > 0 or index(upcase(conditions), "TUMORS") > 0 or
						 index(upcase(conditions), "BREAST") > 0 or index(upcase(conditions), "LUNG") > 0 or index(upcase(conditions), "NSCLC") > 0 or
						 index(upcase(conditions), "PANCRE") > 0 or index(upcase(conditions), "GASTR") > 0 or index(upcase(conditions), "GLIO") > 0 or
						 index(upcase(conditions), "STOMA") > 0 or index(upcase(conditions), "NEOPLASM") > 0 or index(upcase(conditions), "HEPATOCELLULAR") > 0 or
						 index(upcase(conditions), "ESOPH") > 0 or index(upcase(conditions), "MELANOMA") > 0 or index(upcase(conditions), "BRAIN") > 0 or
						 index(upcase(conditions), "ADVANCED MALIGNANCIES") > 0 or index(upcase(conditions), "ADVANCED CANCER") > 0 or 
						 index(upcase(conditions), "PROSTATE CANCER") > 0 or index(upcase(conditions), "HEAD AND NECK") > 0 or 
						 index(upcase(conditions), "RENAL CELL") > 0 or index(upcase(conditions), "SQUAMOUS CELL CARCINOMA") > 0 or 
						 index(upcase(conditions), "HIGH GRADE SEROUS") > 0 or index(upcase(conditions), "PERITONEAL CANCER") > 0 or 
						 index(upcase(conditions), "MULTIPLE INDICATIONS CANCER") > 0 or index(upcase(conditions), "UROTHELIAL CARCINOMA") > 0 or 
						 index(upcase(conditions), " UROTHELIAL CANCER") > 0 or index(upcase(conditions), "COLORECTAL") > 0 or 
						 index(upcase(conditions), "BLADDER CANCER") > 0 or index(upcase(conditions), "BILIARY TRACT CANCER") > 0 or 
						 index(upcase(conditions), "NASOPHARYNGEAL CARCINOMA") > 0 or index(upcase(conditions), "SALIVARY GLAND CARCINOMA") > 0 or 
						 index(upcase(conditions), "PAN TUMOR") > 0 or index(upcase(conditions), "SOLID CANCERS") > 0 or 
						 index(upcase(conditions), "FALLOPIAN TUBE CANCER") > 0 or index(upcase(conditions), "RECTAL") > 0 or 
						 index(upcase(conditions), "LIVER CANCER") > 0 or index(upcase(conditions), "GENITOURINARY CANCER") > 0 or 
						 index(upcase(conditions), "ADRENOCORTICAL CARCINOMA") > 0 or index(upcase(conditions), "PENILE CANCER") > 0 or 
						 index(upcase(conditions), "MERKEL CELL CARCINOMA") > 0 or index(upcase(conditions), "KIDNEY CANCER") > 0 or
						 index(upcase(conditions), "MESOTHELIOMA") > 0 or index(upcase(conditions), "SARCOMA") > 0 or
						 index(upcase(conditions), "CERVICAL CANCER") > 0 or index(upcase(conditions), "UROTHELIAL CANCER") > 0 or 
						 index(upcase(conditions), "ADVANCED METASTATIC CANCER") > 0 or index(upcase(conditions), "MENINGIOMAS") > 0 or
						 index(upcase(conditions), "RENAL CANCER") > 0 or index(upcase(conditions), "SALIVARY GLAND CANCER") > 0 or
						 index(upcase(conditions), "COLON CARCINOMA") > 0 or index(upcase(conditions), "COLON CANCER") > 0 or
						 index(upcase(conditions), "THYROID CANCER") > 0 or index(upcase(conditions), "LEPTOMENINGEAL CARCINOMATOSIS") > 0 or
						 index(upcase(conditions), "LIP, ORAL CAVITY AND PHARYNX") > 0 or index(upcase(conditions), "CHORDOMA") > 0 or
						 index(upcase(conditions), "ORAL CAVITY SCC") > 0 or compress(upcase(conditions)) = "CANCER" or
						 compress(upcase(conditions)) = "CANCER,NOS" or index(upcase(conditions), "BASAL CELL CARCINOMA") > 0 or
						 index(upcase(conditions), "SCCHN") > 0 or index(upcase(conditions), "LEUKOPLAKIA") > 0 or
						 index(upcase(conditions), "OVARIAN CANCER") > 0 or index(upcase(conditions), "SQUAMOUS CELL") > 0 or 
						 index(upcase(conditions), "HEPATIC CARCINOMA") > 0 or index(upcase(conditions), "PROSTATIC CANCER") > 0 or
						 index(upcase(conditions), "SOLID CANCER") > 0 or index(upcase(conditions), "MIXED TUMOR") > 0 or
						 index(upcase(conditions), "CARCINOMA, TRANSITIONAL CELL") > 0 or index(upcase(conditions), "OVARIAN CARCINOMA") > 0 or 
                         index(upcase(conditions), "CANCER OF THE BILE DUCT") > 0 or index(upcase(conditions), "ADENOID CYSTIC CARCINOMA") > 0 or
						 index(upcase(conditions), "BILIARY TRACT CARCINOMA") > 0 or index(upcase(conditions), "PENILE CARCINOMA") > 0 or
						 index(upcase(conditions), "MICROSATELLITE UNSTABLE") > 0 or index(upcase(conditions), "RECURRENT CANCER") > 0 or 
						 index(upcase(conditions), "NASOPHARYNGEAL CANCER") > 0 or index(upcase(conditions), "CANCER OF UNKNOWN") > 0 or
						 index(upcase(conditions), "PENILE CANCER") > 0 or index(upcase(conditions), "ANAL CANCER") > 0 or
						 index(upcase(conditions), "LIVER CARCINOMA") > 0 or index(upcase(conditions), "CARCINOMA, UNSPECIFIED") > 0 or
						 index(upcase(conditions), "CELL CARCINOMA") > 0 or index(upcase(conditions), "MENINGIOMA") > 0 or
						 index(upcase(conditions), "NEUROENDOCRINE CARCINOMA") > 0 or index(upcase(conditions), "ENDOMETRIAL CANCER") > 0 or
						 index(upcase(conditions), "BLADDER CARCINOMA") > 0 or index(upcase(conditions), "SHEATH TUMOUR") > 0 or
						 index(upcase(conditions), "RENAL CARCINOMA") > 0 or index(upcase(conditions), "ADENOCARCINOMA") > 0 or
						 index(upcase(conditions), "GIANT CELL TUMOR OF BONE") > 0
						 );




	%let ii_cond = %str( index(upcase(conditions), "PSORIA") > 0 or index(upcase(conditions), "BEHCET") > 0 or
						 index(upcase(conditions), "SCLERO") > 0 or index(upcase(conditions), "COLITIS") > 0 or index(upcase(conditions), "ULCER") > 0 or
						 index(upcase(conditions), "CROHN") > 0 or index(upcase(conditions), "LUPUS") > 0 or
						 index(upcase(conditions), "LIVER FIBROSIS") > 0 or index(upcase(conditions), "ARTHRITIS") > 0 or
						 index(upcase(conditions), "SJOGREN") > 0 or index(upcase(conditions), "GREN'S SYNDROME") > 0 or 
						 index(upcase(conditions), "CHRONIC GRAFT VERSUS HOST DISEASE") > 0 or
						 index(upcase(conditions), "IGG4-RELATED DISEASE") > 0 or index(upcase(conditions), "MYASTHENIA GRAVIS") > 0 or
						 index(upcase(conditions), "MYOSITIS") > 0 or index(upcase(conditions), "POLYMYALGIA RHEUMATICA") > 0 or
						 index(upcase(conditions), "POLYANGIITIS") > 0 or index(upcase(conditions), "GRANULOMATOSIS") > 0 or
						 index(upcase(conditions), "VASCULITIS") > 0 or index(upcase(conditions), "AUTOIMMUNE") > 0 or
						 index(upcase(conditions), "INFLAMMATION") > 0 or index(upcase(conditions), "AMYLOIDOSIS") > 0 or
						 index(upcase(conditions), "TRANSPLANT") > 0 or index(upcase(conditions), "PROTEINURIA") > 0 or
						 index(upcase(conditions), "FAILING RENAL ALLOGRAFT") > 0 or index(upcase(conditions), "ANTIBODY-MEDIATED REJECTION") > 0 or
						 index(upcase(conditions), "LIVER DYSFUNCTION") > 0 or index(upcase(conditions), "RENAL IMPAIRMENT") > 0 or
						 index(upcase(conditions), "GVHD") > 0 or index(upcase(conditions), "DERMATITIS") > 0 or 
						 index(upcase(conditions), "ECZEMA") > 0 or index(upcase(conditions), "LICHEN PLANUS") > 0 or 
						 index(upcase(conditions), "PALMOPLANTARIS PUSTULOSIS") > 0 or index(upcase(conditions), "PULMONARY FIBROSIS") > 0 or
						 index(upcase(conditions), "FRONTAL FIBROSING") > 0 or index(upcase(conditions), "INFLAMMAT") > 0 or
						 index(upcase(conditions), "BILIARY CHOLANGITIS") > 0 or index(upcase(conditions), "BEHçET'S SYNDROME") > 0
						 );




	%let cv_cond = %str(index(upcase(conditions), "AORTIC") > 0 or index(upcase(conditions), "ARTERY") > 0 or
	                    index(upcase(conditions), "CORONARY") > 0 or index(upcase(conditions), "BYPASS") > 0 or   
						index(upcase(conditions), "GRAFTING") > 0 or index(upcase(conditions), "ATRIAL FIBRILATION") > 0 or  
						index(upcase(conditions), "STROKE") > 0 or index(upcase(conditions), "SYSTEMIC EMBOLISM") > 0 or  
						index(upcase(conditions), "DEEP VENOUS THROMBOSIS") > 0 or index(upcase(conditions), "HEART FAILURE") > 0 or 
						index(upcase(conditions), "THROMBO") > 0 or index(upcase(conditions), "CARDIAC") > 0 or   
						index(upcase(conditions), "MYOCARDIAL") > 0 or index(upcase(conditions), "CONGESTIVE") > 0 or   
						index(upcase(conditions), "HEART") > 0 or index(upcase(conditions), "PROTEINURIA") > 0 or
						index(upcase(conditions), "ATRIAL FIBRILLATION") > 0 or index(upcase(conditions), "PULMONARY EMBOLISM") > 0 or
						index(upcase(conditions), "VENTRICULAR DYSFUNCTION") > 0 or index(upcase(conditions), "VENTRICULAR FAILURE") > 0 or
						index(upcase(conditions), "HYPERTENSION") > 0 or index(upcase(conditions), "KIDNEY DISEASE") > 0 or
						index(upcase(conditions), "CHOLESTEROL") > 0 or index(upcase(conditions), "MITRAL VALVE") > 0 or
						index(upcase(conditions), "SYSTOLIC DYSFUNCTION") > 0 or index(upcase(conditions), "DYSLIPIDEMIA") > 0  
                        );

	%let inf_cond = %str(index(upcase(conditions), "ASPERGILLOSIS") > 0 or index(upcase(conditions), "OTITIS") > 0 or
						 index(upcase(conditions), "COUGH") > 0 or index(upcase(conditions), "PNEUMO") > 0 or
						 index(upcase(conditions), "VIRUS") > 0 or index(upcase(conditions), "RESPIRATORY SYNCYTIAL VIRUSES") > 0 or
						 index(upcase(conditions), "BACTERIA") > 0 or index(upcase(conditions), "FUNG") > 0 or
						 index(upcase(conditions), "VARICELLA") > 0 or index(upcase(conditions), "CMV") > 0 or
						 index(upcase(conditions), "INFECT") > 0 or index(upcase(conditions), "CLOSTRIDIUM") > 0 or
						 index(upcase(conditions), "HPV") > 0 or index(upcase(conditions), "HEPATITIS") > 0 or 
						 index(upcase(conditions), "SEPSIS") > 0 or index(upcase(conditions), "ENDOMETRITIS") > 0 or
						 index(upcase(conditions), "HIV") > 0 );

	%let diab_endo_cond = %str(index(upcase(conditions), "DIABETES") > 0 or index(upcase(conditions), "THYROID") > 0 or
						 index(upcase(conditions), "OSTEOPOROSIS") > 0 or index(upcase(conditions), "ADDISON") > 0 or
						 index(upcase(conditions), "CUSHING") > 0 or index(upcase(conditions), "GRAVE") > 0 or
						 index(upcase(conditions), "HASHIMOTO") > 0 or index(upcase(conditions), "HYPOGONAD") > 0 
						 );



	if &MM_cond then COND_MM="MULTIPLE MYELOMA";
	if &mds_cond then MDS="MDS";
	if &aml_cond then AML="AML";
	if &lym_cond then LYM="LYMPHOMA";
	if &cc_cond then CLL="CLL";
	if &bd_cond then COND_bt="BLOOD DISORDERS";
	if &mf_cond then MF="MF";
	if &st_cond then COND_ST="SOLID TUMORS";
	if &ii_cond then COND_II="INFLAMMATION & IMMUNOLOGY"; 
	if &cv_cond then COND_CV="CARDIOVASCULAR & KIDNEY DISEASE";
	if &leuk_cond then LEUK="LEUKEMIA";
	if &inf_cond then COND_INF="INFECTIOUS DISEASES"; 
	if &diab_endo_cond then COND_DE="DIABETES & ENDOCRINOLOGY DISORDERS";

	if (&leuk_cond) or (&aml_cond) or (&lym_cond) or (&cc_cond) or (&mds_cond) or (&mf_cond) then COND_LL="LEUKEMIA & LYMPHOMA" ;

	if COND_MM = ' ' and mds = ' ' and aml = ' ' and lym = ' ' and cll = ' '
		and COND_bt = ' ' and mf = ' ' and COND_st = ' ' and COND_ii = ' ' and COND_cv = ' ' and leuk = ' ' and COND_INF = ' ' 
		and COND_DE = ' ' then do;
			put "NCTID: " NCT_NUMBER " & Phase: " phases " Condition: " conditions " for Intervention: " interventions " not mapped.";
			put "             ";
			chk_cond = "Y";
			COND_OTH = "OTHER";
	end;


run;


/*
data AMG_ct_da;
	set AMG_ct_da0;

	if index(upcase(Interventions), "ERENUMAB") or index(upcase(compress(Interventions)), "AMG334") > 0 or
	   index(upcase(compress(Interventions)), "AMG-334") > 0
		then AMG_334="ERENUMAB";

	if index(upcase(Interventions), "CARFILZOMIB") or index(upcase(Interventions), "KYPROLIS") or
       index(upcase(compress(Interventions)), "AMG232") > 0 or index(upcase(compress(Interventions)), "AMG-232") > 0
		then AMG_232="ERENUMAB";

	if index(upcase(Interventions), "TALIMOGENE") or index(upcase(Interventions), "IMLYGIC") or
       index(upcase(compress(Interventions)), "AMG678") > 0 or index(upcase(compress(Interventions)), "AMG-678") > 0
		then AMG_678="TALIMOGENE LAHERPAREPVEC";

	if index(upcase(compress(Interventions)), "AMG570") > 0 or index(upcase(compress(Interventions)), "AMG-570") > 0
		then AMG_570="AMG-570";

	if index(upcase(Interventions), "ETELCALCETIDE") or index(upcase(Interventions), "PARSABIV") or
       index(upcase(compress(Interventions)), "AMG416") > 0 or index(upcase(compress(Interventions)), "AMG-416") > 0
		then AMG_416="ETELCALCETIDE";

	if index(upcase(Interventions), "ROMIPLOSTIM") or index(upcase(Interventions), "NPLATE") or
       index(upcase(compress(Interventions)), "AMG531") > 0 or index(upcase(compress(Interventions)), "AMG-531") > 0
		then AMG_531="ROMIPLOSTIM";

	if index(upcase(Interventions), "EVOLOCUMAB") or index(upcase(Interventions), "REPATHA") or
       index(upcase(compress(Interventions)), "AMG145") > 0 or index(upcase(compress(Interventions)), "AMG-145") > 0
		then AMG_145="EVOLOCUMAB";

	if index(upcase(compress(Interventions)), "AMG959") > 0 or index(upcase(compress(Interventions)), "AMG-959") > 0
		then AMG_959="AMG-959";

	if index(upcase(Interventions), "TEZEPELUMAB") or 
       index(upcase(compress(Interventions)), "AMG157") > 0 or index(upcase(compress(Interventions)), "AMG-157") > 0
		then AMG_157="TEZEPELUMAB";

	if index(upcase(Interventions), "OMECAMTIV") or 
       index(upcase(compress(Interventions)), "AMG423") > 0 or index(upcase(compress(Interventions)), "AMG-423") > 0
		then AMG_423="OMECAMTIV MECARBIL";

	if index(upcase(Interventions), "DENOSUMAB") or index(upcase(Interventions), "XGEVA") or
       index(upcase(compress(Interventions)), "AMG162") > 0 or index(upcase(compress(Interventions)), "AMG-162") > 0
		then AMG_162="DENOSUMAB";

	if index(upcase(compress(Interventions)), "AMG510") > 0 or index(upcase(compress(Interventions)), "AMG-510") > 0
		then AMG_510="AMG-510";

	if index(upcase(Interventions), "BLINATUMOMAB") or index(upcase(Interventions), "BLINCYTO") or
       index(upcase(compress(Interventions)), "AMG103") > 0 or index(upcase(compress(Interventions)), "AMG-103") > 0
		then AMG_103="BLINATUMOMAB";

	if index(upcase(compress(Interventions)), "AMG592") > 0 or index(upcase(compress(Interventions)), "AMG-592") > 0
		then AMG_592="AMG-592";

	if index(upcase(Interventions), "CONATUMUMAB") or 
       index(upcase(compress(Interventions)), "AMG655") > 0 or index(upcase(compress(Interventions)), "AMG-655") > 0
		then AMG_655="CONATUMUMAB";

	if index(upcase(Interventions), "GANITUMAB") or 
       index(upcase(compress(Interventions)), "AMG479") > 0 or index(upcase(compress(Interventions)), "AMG-479") > 0
		then AMG_479="GANITUMAB";

	if index(upcase(compress(Interventions)), "ABP959") > 0 or index(upcase(compress(Interventions)), "ABP-959") > 0
		then AMG_ABP959="ABP-959";


	if (index(upcase(Interventions), "OTEZLA") > 0 or index(upcase(Interventions), "APREMILAST") > 0) or
		index(upcase(Interventions), "CC-10004") > 0
		then AMG_OTEZLA="OTEZLA";

run;
*/

proc contents data=rigl_ct_da out=rigl_ct_cont noprint ;
run;


proc sql noprint ;
	select name into: rigl_cc_int separated by " = ' ' and "
	from rigl_ct_cont
	where substr(name,1,3) = "rig" 
	;
quit;

%put &rigl_cc_int. ;

data rigl_cc_int_chk;
	set rigl_ct_da;
	if &rigl_cc_int. = ' ' then do;
		put "NCTID: " NCT_NUMBER " & Intervention: " interventions " & Condition: " conditions " & Phase: " phases " not mapped." ;
		put "             ";
	end;
run;




proc sql noprint ;
	select distinct name into: rigl_int_vars separated by '~'
	from rigl_ct_cont
	where substr(name,1,4) = "rigl" 
	;
    %let intcnt = &sqlobs;
quit;

%put &rigl_int_vars &intcnt;



proc sql noprint ;
	select distinct name into: rigl_cond_vars separated by '~'
	from rigl_ct_cont
	where substr(name,1,5) = "COND_"
	;
    %let condcnt = &sqlobs;
quit;

%put &rigl_cond_vars &condcnt;






%macro cond_int_ph_wt(anlz_ds=, cond_mvar=, num_cond=, int_mvar=, num_int=);


	%do j =1 %to &condcnt. ;
		%let cond = %scan(&cond_mvar., &j , '~');
		%put Condition = &cond. ;
		    %do i = 1 %to &intcnt. ;
		       %let single = %scan(&int_mvar., &i , '~');
		       %put single = &single;
					proc freq data=&anlz_ds. noprint ;
						   table spnsr*&cond.*&single.*phases  / missing out=__&cond._&single.(where=(&single. ne " " and &cond. ne " " ) 
																					     drop=percent) ;
					run;

					proc sql noprint ;
						select count(&cond.) into: cond_chk_cnt
						from __&cond._&single.
						;
					quit;

					%if &cond_chk_cnt. > 0 %then %do;
						data __&cond._&single.;
							length cond int phases $200.;
							set __&cond._&single.;
								cond=&cond.;
								INT=&single. ;
								drop &cond. &single. ;
						run;
					%end;

					%else %do;
						proc datasets lib=work nolist;
							delete __&cond._&single.;
						quit;
						run;
					%end;
		    %end;
	%end;

%mend cond_int_ph_wt;


%cond_int_ph_wt(anlz_ds=rigl_ct_da, cond_mvar=&rigl_cond_vars., num_cond=&condcnt., int_mvar=&rigl_int_vars., num_int=&intcnt.);


	data all_cond_int_ph;
		length cond int phases $200.;
		set __cond_:;

		*cond1 = strip(put(cond, $condlbl.));
			int  = strip(int);
			phases=strip(phases);

			do i=1 to count;
				output;
			end;
	run;


		



%macro sankey_nodes(inds=all_cond_int_ph, outds=, nodes=%str(spnsr|cond|int|phases), cond=);

	%let cnt = %eval(%sysfunc(countc(&nodes.,"|")) +1);
	%put &cnt.;

	   data _inds;
	   	set &inds.;
		run;

    %do i = 1 %to &cnt;
       %let single&i. = %scan(&nodes, &i , '|');
       %put single&i. = &&single&i;
	%end;


		proc sql;
		    %do i = 1 %to %eval(&cnt. -1);
				create table &&single&i.._wt_chk as
					select distinct 
						%do k=1 %to &i. ;
							&&single&k.,
						%end;
						%superq(single%eval(&i. +1)), &&single&i. as SOURCE length=100,  %superq(single%eval(&i. +1)) as TARGET length=100, count(&&single&i.) as VALUE,	
								"            	{'source':'"||strip(&&single&i.)||"','target':'"||strip(%superq(single%eval(&i. +1)))||"','value':"||strip(put(count(&&single&i.), 5.0))||"}," as final length=1000
					from _inds
					%if &cond. ne %then %do;
						where &cond.
					%end;
					group by 
						%do k=1 %to &i. ;
							&&single&k., 
						%end;
						%superq(single%eval(&i. +1))
					;
			%end;
		quit;


		data &outds.;
			set 
		    %do i = 1 %to %eval(&cnt. -1);
				&&single&i.._wt_chk
			%end;
			;
		run;

		options linesize=max;
		%global sankeydata;

		proc sql noprint;
			select final into: sankeydata separated by " "
			from &outds.
			;
		quit;

		%put &sankeydata. ;

%mend sankey_nodes;

%sankey_nodes(inds=all_cond_int_ph, outds=outds.rigl_sankey, nodes=%str(spnsr|cond|int|phases), cond=);

%include "/u02/projects/sp_standard_programs/sp_general_001/deliverables/d002_sankey_diagram_2020/programs/macros/final/sankey2html.sas";

%sankey2html(in_data=%nrbquote(&sankeydata.), outfl=%sysfunc(pathname(outg,f))/rigl.html, width=1900, height=600, flow_num=);



proc datasets lib=work kill memtype=data nodetails ;
run;

