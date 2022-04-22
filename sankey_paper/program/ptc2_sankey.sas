
libname inds "/u02/home/tkhole/sankey_paper/input_data" ;
filename infl "/u02/home/tkhole/sankey_paper/input_data" ;

libname outds "/u02/home/tkhole/sankey_paper/output_data" ;
filename outg "/u02/home/tkhole/sankey_paper/output_html";




options validvarname=V7;
options validvarname=upcase;

%macro get_ds(fl=, outds=);
proc import datafile="%sysfunc(pathname(infl,f))/&fl..csv"
     out=&outds.(where=(phases not in ( ' ' 'Not Applicable') and Interventions ne ' ' /*and status in ("Active, not recruiting" 
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

%get_ds(fl=ptc, outds=ptc_ct);


/*
index(lowcase(SPONSOR_COLLABORATORS), "ptc therapeutics")>0
*/

/**********STEP 1 - Data Analysis*************/
data PTC_ct_;
	set PTC_ct(in=a);

	  if substr(strip(lowcase(sponsor_collaborators)), 1, 3) = "ptc" ;

	  SPNSR="PTC Therapeutics";

	  *if phases in ("Early Phase 1" "Phase 1") then delete;

	  if phases = "Phase 1|Phase 2" then phases = "Phase 2";
	  if phases = "Phase 2|Phase 3" then phases = "Phase 3";
	  phases = upcase(phases);

	  org_status=status;
	  if status in ("Active, not recruiting" 
      "Available"  
      "Enrolling by invitation"  
      "Not yet recruiting"
      "Recruiting") then status = "On-going";
run;


proc freq data=PTC_ct_ noprint ;
	table Status / list missing out= PTC_status;
	table Study_Results / list missing ;
	table Conditions / list missing out=PTC_cond;
	table Interventions / list missing out=PTC_int;
	table Outcome_Measures / list missing out=PTC_out_meas;
	table Phases / list missing out=PTC_phases;
	table SPNSR / list missing out=spnsr_wt;
	table SPNSR*Status*Interventions*Conditions*Phases / list missing out=PTC_wt;

run;



data PTC_ct_da0;
	set PTC_ct_;

	/*Conditions*/

	%let gen_cond=%str(index(upcase(conditions), "AADC DEFICIENCY") > 0 or index(upcase(conditions), "AMINO ACID METABOLISM") > 0 or
						index(upcase(conditions), "INBORN ERRORS") > 0 or index(upcase(conditions), "ANIRIDIA") > 0  or 
						index(upcase(conditions), "BH4 DEFICIENCY") > 0 or 	index(upcase(conditions), "CYSTIC FIBROSIS") or
						index(upcase(conditions), "MUSCULAR DYSTROPHY") > 0 or index(upcase(conditions), "DYSTROPHINOPATHY") > 0 or
						index(upcase(conditions), "HEMOPHILIA") > 0 or index(upcase(conditions), "MITOCHONDRIAL DISEASES") > 0 or
						index(upcase(conditions), "MITOCHONDRIAL ENCEPHALOPATHY") > 0 or index(upcase(conditions), "PONTOCEREBELLAR HYPOPLASIA TYPE 6") > 0 or
						index(upcase(conditions), "NEUROFIBROMATOSIS 2") > 0 or index(upcase(conditions), "FRIEDREICH ATAXIA") > 0 or 
						index(upcase(conditions), "FRIEDREICH'S ATAXIA") > 0);

	%let met_cond=%str(index(upcase(conditions), "PHENYLKETONURIA") > 0 or index(upcase(conditions), "HYPERPHENYLALANINEMIA") > 0 );


	%let onc_cond = %str(index(upcase(conditions), "AML") > 0 or index(upcase(conditions), "MYELOID") > 0 or 
						 index(upcase(conditions), "MYELOGENOUS") > 0 or index(upcase(conditions), "LEUKEMIA") > 0 or
						 index(upcase(conditions), "LEIOMYOSARCOMA") > 0 or index(upcase(conditions), "ADVANCED CANCER") > 0 or
						 index(upcase(conditions), "CANCER") > 0 or index(upcase(conditions), "LEIOMYOSARCOMA") > 0);

 
	%let neuro_cond=%str(index(upcase(conditions), "AMYOTROPHIC LATERAL SCLEROSIS") > 0 or index(upcase(conditions), "LEIGH SYNDROME") > 0 or
						 index(upcase(conditions), "ALPERS DISEASE") > 0 or index(upcase(conditions), "NEUROMUSCULAR DISEASES") > 0 or
						 index(upcase(conditions), "NERVOUS SYSTEM DISEASES") > 0 or index(upcase(conditions), "PARKINSON") > 0);


	%let gastro_cond=%str(index(upcase(conditions), "GASTROPARESIS") > 0 );

	%let hepat_cond=%str(index(upcase(conditions), "HEPATIC IMPAIRMENT") > 0 );

	%let covid_cond=%str(index(upcase(conditions),"COVID-19") > 0 or index(upcase(conditions),"CORONAVIRUS") > 0 );

	%let renal_cond=%str(index(upcase(conditions), "RENAL IMPAIRMENT") > 0 );

	%let healthy_cond=%str(index(upcase(conditions), "HEALTHY") > 0 );



	if &gen_cond then COND_GEN="GENETIC DISORDERS";
	if &met_cond then COND_MET="METABOLIC DISORDERS";
	if &onc_cond then COND_ONC="ONCOLOGY";
	if &neuro_cond then COND_NEURO = "NEUROLOGICAL DISORDERS";
	if &gastro_cond then COND_GASTRO = "GASTRIC DISORDERS";
	if &hepat_cond then COND_HEPAT = "HEPATIC DISORDERS";
	if &covid_cond then COND_COVID = "COVID-19";
	if &renal_cond then COND_HEPAT = "RENAL DISORDERS";
	if &healthy_cond then COND_HEALTH = "HEALTHY SUBJECTS";

	if COND_MM = ' ' and mds = ' ' and aml = ' ' and lym = ' ' and cll = ' '
		and COND_bt = ' ' and mf = ' ' and COND_st = ' ' and COND_ii = ' ' and COND_cv = ' ' and leuk = ' ' and COND_INF = ' ' 
		and COND_DE = ' ' and COND_NEURO = ' '  and COND_GEN = ' ' and COND_MET = ' ' and COND_ONC = ' ' and COND_GASTRO = ' ' 
		and COND_HEPAT = ' ' and COND_COVID = ' ' and COND_RENAL = ' ' and COND_HEALTH = ' ' then do;
			put "NCTID: " NCT_NUMBER " & Phase: " phases " Condition: " conditions " for Intervention: " interventions " not mapped.";
			put "             ";
			chk_cond = "Y";
			COND_OTH = "OTHER";
	end;


run;


data ptc_ct_da;
	set ptc_ct_da0;

	/*PTC Interventions*/
	if index(upcase(Interventions), "ATALUREN") > 0 or index(upcase(compress(Interventions)), "PTC124") > 0 or
	   index(upcase(Interventions), "TRANSLARNA") > 0 then PTC_ATALUREN="ATALUREN [PTC124]";

	if index(upcase(compress(Interventions)), "CNSA-001") > 0 or index(upcase(compress(Interventions)), "SEPIAPTERIN") > 0 or 
		index(upcase(compress(Interventions)), "PTC923") > 0 
		then PTC_923="PTC923";

	if index(upcase(compress(Interventions)), "DEFLAZACORT") > 0 or index(upcase(compress(Interventions)), "EMFLAZA") > 0 
		then PTC_DEFLAZACORT="DEFLAZACORT";

	if index(upcase(compress(Interventions)), "EPI-589") > 0  
		then PTC_EPI_589="EPI-589";

	if index(upcase(compress(Interventions)), "EPI-743") > 0 or index(upcase(compress(Interventions)), "VATIQUINONE") > 0
		then PTC_VATIQUINONE="VATIQUINONE [EPI-743]";

	if index(upcase(Interventions), "EMVODODSTAT") > 0 or index(upcase(compress(Interventions)), "PTC299") > 0 
		then PTC_EMVODODSTAT="EMVODODSTAT [PTC299]";

	if index(upcase(compress(Interventions)), "PTC596") > 0  or index(upcase(compress(Interventions)), "UNESBULIN") > 0
		then PTC_596="UNESBULIN [PTC596]";

	if index(upcase(compress(Interventions)), "ELADOCAGENEEXUPARVOVEC") > 0  
		then PTC_AADC="ELADOCAGENE EXUPARVOVEC [PTC-AADC]";

run;



proc contents data=ptc_ct_da out=ptc_ct_cont noprint ;
run;


proc sql noprint ;
	select name into: ptc_cc_int separated by " = ' ' and "
	from ptc_ct_cont
	where substr(name,1,3) = "PTC" 
	;
quit;

%put &ptc_cc_int. ;

data ptc_cc_int_chk;
	set ptc_ct_da;
	if &ptc_cc_int. = ' ' then do;
		put "Sponsor: " SPNSR " & Condition: " conditions " & Intervention: " interventions " & Phase: " phases " not mapped";
	end;
run;


proc sql noprint ;
	select distinct name into: ptc_int_vars separated by '~'
	from ptc_ct_cont
	where substr(name,1,3) = "PTC" 
	;
    %let intcnt = &sqlobs;
quit;

%put &ptc_int_vars &intcnt;



proc sql noprint ;
	select distinct name into: ptc_cond_vars separated by '~'
	from ptc_ct_cont
	where substr(name,1,5) = "COND_"
	;
    %let condcnt = &sqlobs;
quit;

%put &ptc_cond_vars &condcnt;




%macro cond_int_ph_wt(anlz_ds=, cond_mvar=, num_cond=, int_mvar=, num_int=);


	%do j =1 %to &condcnt. ;
		%let cond = %scan(&cond_mvar., &j , '~');
		%put Condition = &cond. ;
		    %do i = 1 %to &intcnt. ;
		       %let single = %scan(&int_mvar., &i , '~');
		       %put single = &single;
					proc freq data=&anlz_ds. noprint ;
						   table spnsr*&cond.*&single.*phases*status  / missing out=__&cond._&single.(where=(&single. ne " " and &cond. ne " " ) 
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


%cond_int_ph_wt(anlz_ds=ptc_ct_da, cond_mvar=&ptc_cond_vars., num_cond=&condcnt., int_mvar=&ptc_int_vars., num_int=&intcnt.);


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

%sankey_nodes(inds=all_cond_int_ph, outds=outds.ptc_sankey, nodes=%str(spnsr|cond|int|phases|status), cond=);

%include "/u02/projects/sp_standard_programs/sp_general_001/deliverables/d002_sankey_diagram_2020/programs/macros/final/sankey2html.sas";

%sankey2html(in_data=%nrbquote(&sankeydata.), outfl=%sysfunc(pathname(outg,f))/ptc.html, width=1900, height=400, flow_num=);



proc datasets lib=work kill memtype=data ;
run;
		
















