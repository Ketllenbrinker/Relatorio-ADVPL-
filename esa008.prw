#INCLUDE "protheus.ch"


//-------------------------------------------------------------------
/*/{Protheus.doc} ESA008
Programa de ExibiÃ§Ã£o e ImpressÃ£o de relatÃ³rio

@author  KETLLEN BRINKER TOGNETTI
@since   23/03/2022
@return  Boolean, Sempre verdadeiro
/*/
//-------------------------------------------------------------------

User Function ESA008()

	Local oReport

	Private aCampo := {}

	oReport := U_ReportDef()

	oReport:SetPortrait()

	oReport:PrintDialog()

Return

User Function ReportDef()

	Local oCell

	Local oSection

	Local oReport := TReport():New( "ESA008", OEMTOANSI( "Relatório de Notas" ), "ESA008", {|oReport| U_ReportPrint(oReport)}, "Descrição do Relatório" )

	oReport:ShowParamPage()
	oReport:lParamPage := .F.

	oReport:lHeaderVisible := .F.

	oSection := TRSection():New( oReport, "", "" )
	oSection2 := TRSection():New( oReport , "" , "" )

	oCell := TRCell():New( oSection, "Matrícula"   , NIL, NIL, NIL, 13, NIL, {||aCampo[nPos,01]} )
	oCell := TRCell():New( oSection, "Aluno"       , NIL, NIL, NIL, 40, NIL, {||aCampo[nPos,02]} )
	oCell := TRCell():New( oSection, "Cód. Turma"  , NIL, NIL, NIL, 08, NIL, {||aCampo[nPos,03]} )
	oCell := TRCell():New( oSection, "Turma"       , NIL, NIL, NIL, 30, NIL, {||aCampo[nPos,04]} )
	oCell := TRCell():New( oSection, "Cód. Matéria", NIL, NIL, NIL, 08, NIL, {||aCampo[nPos,05]} )
	oCell := TRCell():New( oSection, "Matéria"     , NIL, NIL, NIL, 25, NIL, {||aCampo[nPos,06]} )
	oCell := TRCell():New( oSection, "Nota"        , NIL, NIL, NIL, 22, NIL, {||aCampo[nPos,07]} )
	oCell := TRCell():New( oSection, "Data"        , NIL, NIL, NIL, 10, NIL, {||aCampo[nPos,08]} )
	oCell := TRCell():New( oSection, "Cód. Prof"   , NIL, NIL, NIL, 11, NIL, {||aCampo[nPos,09]} )
	oCell := TRCell():New( oSection, "Profesor"    , NIL, NIL, NIL, 40, NIL, {||aCampo[nPos,10]} )

	oCell := TRCell():New( oSection2, "", NIL, NIL, NIL, 40, NIL, {||"Total alunos: "      + CValToChar( ( Len( aAlunCount ) -1 ) ) } )
	oCell := TRCell():New( oSection2, "", NIL, NIL, NIL, 40, NIL, {||"Total matérias: "    + CValToChar( ( Len( aMateCount ) -1 ) ) } )
	oCell := TRCell():New( oSection2, "", NIL, NIL, NIL, 40, NIL, {||"Total disciplinas: " + CValToChar( ( Len( aDiscCount ) -1 ) ) } )
	oCell := TRCell():New( oSection2, "", NIL, NIL, NIL, 40, NIL, {||"Total turmas: "      + CValToChar( ( Len( aTurmCount ) -1 ) ) } )
	oCell := TRCell():New( oSection2, "", NIL, NIL, NIL, 40, NIL, {||"Nota maior: "        + CValToChar( nNotaMaior ) } )
	oCell := TRCell():New( oSection2, "", NIL, NIL, NIL, 40, NIL, {||"Nota menor: "        + CValToChar( nNotaMenor ) } )

Return oReport

User Function ReportPrint(oReport)

	Local oSection := oReport:Section(1)
	Local oSection2 := oReport:Section(2)

	Local cAlias := GetNextAlias()

	Local ni

	Private nNotaMaior
	Private nNotaMenor

	Private aDiscCount := {""}
	Private aTurmCount := {""}
	Private aAlunCount := {""}
	Private aMateCount := {""}

	Private nPos

	If Mv_Par02 = ""
		Mv_Par02 := "zzzzzzzzz"
	EndIf

	If Mv_Par04 = ""
		Mv_Par04 := "zzzzz"
	EndIf

	If Mv_Par06 = ""
		Mv_Par06 := "zzzzzz"
	EndIf

	BeginSql Alias cAlias

		SELECT 
			ZZ7.ZZ7_MATAL,  ZZ2.ZZ2_NOME, ZZ7.ZZ7_TURMA, ZZ4.ZZ4_DESCT, ZZ7.ZZ7_CODMAT,
			ZZ3.ZZ3_DESCRI, ZZ7.ZZ7_MAT,  ZZ1.ZZ1_NOME,  ZZ7.ZZ7_NOTA,  ZZ7.ZZ7_DATA, ZZ6.ZZ6_DISC
		FROM
			%table:ZZ7% ZZ7
			INNER JOIN %table:ZZ1% ZZ1 ON
				ZZ7.ZZ7_MAT = ZZ1.ZZ1_MAT
					AND ZZ7.ZZ7_FILIAL = ZZ1.ZZ1_FILIAL
					AND ZZ1.%notDel%
					
			INNER JOIN %table:ZZ2% ZZ2 ON 
				ZZ7.ZZ7_MATAL = ZZ2.ZZ2_MATAL  
					AND ZZ7.ZZ7_FILIAL = ZZ2.ZZ2_FILIAL
					AND ZZ2.%notDel%

			INNER JOIN %table:ZZ3% ZZ3 ON 
				ZZ7.ZZ7_CODMAT = ZZ3.ZZ3_CODMAT 
					AND ZZ7.ZZ7_FILIAL = ZZ3.ZZ3_FILIAL
					AND ZZ3.%notDel%

			INNER JOIN %table:ZZ4% ZZ4 ON
				ZZ7.ZZ7_TURMA = ZZ4.ZZ4_TURMA
					AND ZZ7.ZZ7_FILIAL = ZZ4.ZZ4_FILIAL
					AND ZZ4.%notDel%

			INNER JOIN %table:ZZ6% ZZ6 ON
				ZZ7.ZZ7_DISC = ZZ6.ZZ6_DISC
					AND ZZ4.ZZ4_FILIAL = ZZ6.ZZ6_FILIAL
					AND ZZ6.%notDel%
			
			WHERE   ZZ7.ZZ7_MATAL BETWEEN %Exp:Mv_Par01% And %Exp:Mv_Par02%
				AND ZZ6.ZZ6_DISC  BETWEEN %Exp:Mv_Par03% And %Exp:Mv_Par04%
				AND ZZ7.ZZ7_TURMA BETWEEN %Exp:Mv_Par05% And %Exp:Mv_Par06%

			GROUP BY ZZ7.ZZ7_MATAL,  ZZ2.ZZ2_NOME, ZZ7.ZZ7_TURMA, ZZ4.ZZ4_DESCT, ZZ7.ZZ7_CODMAT,
			         ZZ3.ZZ3_DESCRI, ZZ7.ZZ7_MAT,  ZZ1.ZZ1_NOME,  ZZ7.ZZ7_NOTA,  ZZ7.ZZ7_DATA, ZZ6.ZZ6_DISC
		
			ORDER BY ZZ2.ZZ2_NOME

	EndSql

	( cAlias )->( DbGoTop() )

	nNotaMaior := ( cAlias )->ZZ7_NOTA
	nNotaMenor := ( cAlias )->ZZ7_NOTA

	While ( cAlias )->( !EoF() )

		aAdd(aCampo, {;
			( cAlias )->ZZ7_MATAL,;
			( cAlias )->ZZ2_NOME,;
			( cAlias )->ZZ7_TURMA,;
			( cAlias )->ZZ4_DESCT,;
			( cAlias )->ZZ7_CODMAT,;
			( cAlias )->ZZ3_DESCRI,;
			( cAlias )->ZZ7_NOTA,;
			( cAlias )->ZZ7_DATA,;
			( cAlias )->ZZ7_MAT,;
			( cAlias )->ZZ1_NOME;
			})

		If ( cAlias )->ZZ7_NOTA > nNotaMaior
			nNotaMaior := ( cAlias )->ZZ7_NOTA
		EndIf

		If ( cAlias )->ZZ7_NOTA < nNotaMenor
			nNotaMenor := ( cAlias )->ZZ7_NOTA
		EndIf

		If aSCAN(aDiscCount, ( cAlias )->ZZ6_DISC) = 0
			Aadd(aDiscCount,( cAlias )->ZZ6_DISC)
		EndIf

		If aSCAN(aAlunCount, ( cAlias )->ZZ7_MATAL) = 0
			Aadd(aAlunCount,( cAlias )->ZZ7_MATAL)
		EndIf

		If aSCAN(aTurmCount, ( cAlias )->ZZ7_TURMA) = 0
			Aadd(aTurmCount,( cAlias )->ZZ7_TURMA)
		EndIf

		If aSCAN(aMateCount, ( cAlias )->ZZ7_CODMAT) = 0
			Aadd(aMateCount,( cAlias )->ZZ7_CODMAT)
		EndIf

		( cAlias )->( DbSkip() )

	End

	( cAlias )->( DbCloseArea() )

	oSection2:Init( .F. )

	oSection2:PrintLine()

	oReport:SkipLine()

	oReport:FatLine()

	for ni := 1 to Len(aCampo)

		nPos := ni

		oSection:Init( .F. )

		oSection:PrintLine()

	next

	oSection:Finish()
	oSection2:Finish()

Return











