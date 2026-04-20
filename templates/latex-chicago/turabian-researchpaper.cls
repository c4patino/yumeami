% Turabian Formatting for LaTeX
%
% Based on Kate L. Turabian's "A Manual for Writers of Research Papers, Theses,
% and Dissertations," 9th edition.
%
% ==============================
% Copyright 2013-2018 Omar Abdool
%
% This work may be distributed and/or modified under the conditions of the LaTeX
% Project Public License (LPPL), either version 1.3 of this license or (at your
% option) any later version.
%
% The latest version of this license is in:
%	http://www.latex-project.org/lppl.txt
% and version 1.3 or later is part of all distributions of LaTeX version
% 2005/12/01 or later.
%
% LPPL Maintenance Status: maintained (by Omar Abdool)
%
% This work consists of the files: turabian-formatting.sty,
% turabian-researchpaper.cls, turabian-thesis.cls, turabian-formatting-doc.tex,
% and turabian-formatting-doc.pdf (in addition to the README file).
%
% ==============================
%
%


\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{turabian-researchpaper}[2018/08/01 Turabian Research Paper]


% Default point size
\def\@@ptsize{12pt}


% Document class options: handling

\DeclareOption{raggedright}{%
	\PassOptionsToPackage{\CurrentOption}{turabian-formatting}}

\DeclareOption{authordate}{%
	\PassOptionsToPackage{\CurrentOption}{turabian-formatting}}

\DeclareOption{noadjustbib}{%
	\PassOptionsToPackage{\CurrentOption}{turabian-formatting}}

\DeclareOption{endnotes}{%
	\PassOptionsToPackage{\CurrentOption}{turabian-formatting}}

\DeclareOption{twocolumn}{%
	\ClassWarningNoLine{turabian-researchpaper}{The '\CurrentOption' option is not supported}
	\OptionNotUsed}

\DeclareOption{10pt}{\def\@@ptsize{10pt}}

\DeclareOption{11pt}{\def\@@ptsize{11pt}}

\DeclareOption{12pt}{\def\@@ptsize{12pt}}

\DeclareOption{emptymargins}{%
	\ClassWarningNoLine{turabian-researchpaper}{The '\CurrentOption' option is no longer available}
	\OptionNotUsed}

\DeclareOption{endnotesonly}{%
	\ClassWarningNoLine{turabian-researchpaper}{The '\CurrentOption' option has been deprecated. Consider using the 'endnotes' option instead}
	\OptionNotUsed}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}

\ProcessOptions\relax


% Load "article" document class with options
\LoadClass[titlepage,oneside,onecolumn,\@@ptsize]{article}


% Load turabian-formatting package
\RequirePackage{turabian-formatting}


% Part: formatting
\def\tf@partformat{\normalfont\bfseries\singlespacing\centering}

\def\@part[#1]#2{%
	\ifnum \c@secnumdepth >-2\relax
		\refstepcounter{part}%
		\addcontentsline{toc}{part}%
			{\protect{\partname\space\thepart}}%
	\else
		\addcontentsline{toc}{part}{#1}%
	\fi
	\markboth{}{}%
	{	\tf@partformat
		\interlinepenalty \@M
		\ifnum \c@secnumdepth >-2\relax
			\partname\nobreakspace\thepart
			\par\nobreak
			\vspace*{1\baselineskip}%
		\fi
		\ifstrempty{#2}%
			{}%
			{#2\par\nobreak}}%
	\vspace{\dimexpr 3\tf@singlelineskip -\baselineskip \relax}}

\def\@spart#1{%
	{	\tf@partformat
		\interlinepenalty \@M
		#1\par\nobreak}%
	\vspace{\dimexpr 3\tf@singlelineskip -\baselineskip \relax}}


% Sections: command to disable differentiate and reformat \section*
\gdef\noadjustssect{\@adjustssectionfalse}

% Sections: \section* adjustment to space after heading
\newif\if@adjustssection\@adjustssectiontrue
\newlength\tf@ssect@afterskip
\setlength\tf@ssect@afterskip{1\p@}

% Sections: adjustment to space after \section heading
\newif\if@tf@adjustsection\@tf@adjustsectionfalse
\newlength\tf@sect@afterskip
\setlength\tf@sect@afterskip{1\p@}

% Sections: redefine \@startsection to differentiate starred version
\def\@startsection#1#2#3#4#5#6{%
	\if@noskipsec \leavevmode \fi
	\par
	\@tempskipa #4\relax
	\@afterindenttrue
	\ifdim \@tempskipa <\z@
		\@tempskipa -\@tempskipa \tf@afterindent
	\fi
	\if@nobreak \everypar{} \else
		\addpenalty\@secpenalty\addvspace\@tempskipa
	\fi
	\setlength\tf@ssect@afterskip{\dimexpr #5 -\tf@adjaftersec \relax}
	\if@adjustssection
		\ifstrequal{#1}{section}%
			{\setlength\tf@ssect@afterskip{%
				\dimexpr 2\tf@singlelineskip -\tf@adjaftersec \relax}}%
			{}
	\fi
	\setlength\tf@sect@afterskip{\dimexpr #5 -\tf@adjaftersec \relax}
	\if@tf@adjustsection
		\ifstrequal{#1}{section}%
			{\setlength\tf@sect@afterskip{%
				\dimexpr 2\tf@singlelineskip -\tf@adjaftersec \relax}}%
			{}
	\fi
	\@ifstar
		{\@ssect{#3}{#4}{\tf@ssect@afterskip}{#6}}%
		{\@dblarg{\@sect{#1}{#2}{#3}{#4}{\tf@sect@afterskip}{#6}}}}

% Sections: formatting between \@svsec and heading
\protected@edef\tf@secsep#1#2{\@empty}

% Sections: formatting of TOC \addcontentsline
\def\tf@tocline#1{\protect{\csname the#1\endcsname\quad}}

% Sections: redefine \@sect to support optional two-line formatting
\def\@sect#1#2#3#4#5#6[#7]#8{%
	\ifnum #2>\c@secnumdepth
		\let\@svsec\@empty
	\else
		\refstepcounter{#1}%
		\protected@edef\@svsec{\@seccntformat{#1}\relax}%
	\fi
	\@tempskipa #5\relax
	\ifdim \@tempskipa>\z@
		\begingroup
			#6{%
				\@hangfrom{\hskip #3\relax\@svsec}%
				\interlinepenalty \@M \tf@secsep{#1}{#8}#8\@@par}%
		\endgroup
		\csname #1mark\endcsname{#7}%
		\addcontentsline{toc}{#1}{%
			\ifnum #2>\c@secnumdepth \else
				\tf@tocline{#1}%
			\fi
			#7}%
	\else
		\def\@svsechd{%
			#6{\hskip #3\relax\@svsec #8}%
			\csname #1mark\endcsname{#7}%
			\addcontentsline{toc}{#1}{%
				\ifnum #2>\c@secnumdepth \else
					\tf@tocline{#1}%
				\fi
				#7}}%
	\fi
	\@xsect{#5}}


% Title page: commands for use with \maketitle
\newcommand{\subtitle}[1]{\gdef\tf@subtitle{#1}}
\subtitle{}

\newcommand{\tf@subtitlesep}{\ifdefempty{\tf@subtitle}{}{:}}

\newcommand{\submissioninfo}[1]{\gdef\tf@submissioninfo{#1}}
\submissioninfo{}

\newcommand{\course}[1]{\gdef\tf@course{#1}}
\course{}

% Title page: command for emptying/completing \maketitle
\newcommand{\tf@emptymaketitle}{%
	\global\let\thanks\relax
	\global\let\maketitle\relax

	\global\let\@thanks\@empty
	\global\let\@author\@empty
	\global\let\@date\@empty
	\global\let\@title\@empty
	\global\let\tf@subtitle\@empty
	\global\let\tf@submissioninfo\@empty
	\global\let\tf@course\@empty

	\global\let\title\relax
	\global\let\author\relax
	\global\let\date\relax
	\global\let\subtitle\relax
	\global\let\submissioninfo\relax
	\global\let\course\relax}

% Title page: renew \maketitle command research paper
\if@titlepage
	% Formatting for titlepage option
	\renewcommand{\maketitle}{%
		\begin{titlepage}%
			\tf@setfnpunct{}
			\renewcommand*{\thefootnote}{\fnsymbol{footnote}}
			\let\footnoterule\relax
			\normalfont\normalsize\centering\singlespacing
			\parskip=1\baselineskip
			\vspace*{-2\baselineskip}
			\vspace*{0.333\paperheight}
			\vspace*{-1in}
			{	\bfseries\@title\tf@subtitlesep\par%
				\tf@subtitle\par}%
			\vspace*{2.35in}
			\@author\@thanks\par
			\tf@course\par
			\tf@submissioninfo\par
			\@date\par
			\parskip=\z@
		\end{titlepage}%
		% if not endnotes, reset footnote counter
		\if@endnotesformat \else \setcounter{footnote}{0} \fi
		\tf@emptymaketitle
		\cleardoublepage}
\else
	% Formatting for notitlepage option
	\renewcommand{\maketitle}{%
		\thispagestyle{plain}
		{	\renewcommand*{\thefootnote}{\fnsymbol{footnote}}
			\normalfont\normalsize\centering\singlespacing
			\parskip=1\baselineskip
			\vspace*{0.5in}
			\vspace*{-1.5\baselineskip}
			{	\bfseries\@title\tf@subtitlesep\par%
				\tf@subtitle\par}%
			\vspace*{1\baselineskip}
			\@author\@thanks\par
			\tf@course\par
			\tf@submissioninfo\par
			\@date\par
			\vspace*{0.5in}
			\vspace*{-1\baselineskip}}
		% if not endnotes, reset footnote counter
		\if@endnotesformat \else \setcounter{footnote}{0} \fi
		\tf@emptymaketitle}
\fi


% Table of Contents, List of Figures, and List of Tables: item number alignment
%\def\numberline#1{\hb@xt@\@tempdima{\hfil #1\hspace{1em}}}

\def\@tocrmarg{0.75in}
\def\@pnumwidth{3.5ex}


% Table of Contents: formatting
\setcounter{tocdepth}{1}

\renewcommand*{\l@part}[2]{%
	\ifnum \c@tocdepth >-2\relax
		\addpenalty{-\@highpenalty}%
		\addvspace{1\baselineskip}%
		\setlength\@tempdima{0.5in}%
		\vskip \tf@singlelineskip
		{	\parindent \z@
			\rightskip \z@
			\parfillskip -\@rightskip
			\leavevmode
			\advance\leftskip\@tempdima
			\hskip -\leftskip
			\bfseries #1\nobreak\hfil \nobreak\par}
	\fi}

\renewcommand*{\l@section}[2]{%
	\ifnum \c@tocdepth >\z@
		\addpenalty\@secpenalty
		\setlength\@tempdima{\z@}%
		\vskip \tf@singlelineskip
		{	\parindent \z@
			\rightskip \@tocrmarg
			\parfillskip -\rightskip
			\leavevmode
			\advance\leftskip\@tempdima
			\hskip -\leftskip
			#1\nobreak\hfil \nobreak\hb@xt@\@pnumwidth{\hss #2}\par}
	\fi}

\renewcommand*{\l@subsection}{%
	\ifnum \c@tocdepth >1 \vskip \tf@singlelineskip \fi
	\@dottedtocline{2}{0.5in}{\z@}}

\renewcommand*{\l@subsubsection}{%
	\ifnum \c@tocdepth >2 \vskip \tf@singlelineskip \fi
	\@dottedtocline{3}{1.0in}{\z@}}


% List of Figures: formatting
\renewcommand*\l@figure{
	\vskip \tf@singlelineskip
	\@dottedtocline{1}{1em}{0.5in}}


% List of Tables: formatting
\def\l@table{\l@figure}


% Abstract: formatting
\renewenvironment{abstract}%
	{%
		\clearpage
		\section*{\abstractname}
	}%
	{\clearpage}


% Appendixes: adjust formatting of section headings
\def\tf@appendixsecfrmt{%
	\DeclareRobustCommand{\@seccntformat}[1]{%
		\ifstrequal{##1}{section}%
			{\appendixname\space \csname the##1\endcsname}%
			{\csname the##1\endcsname\quad}}
	\DeclareRobustCommand{\tf@secsep}[2]{%
		\ifstrequal{##1}{section}%
			{\ifstrempty{##2}{}{\par\nobreak}}%
			{\@empty}}
	\def\tf@tocline##1{\appendixname\space \csname the##1\endcsname.\quad}
	\@tf@adjustsectiontrue}

% Appendixes: make environment
\newenvironment{appendixes}%
	{%
		\setcounter{secnumdepth}{1}
		\tf@appendixsecfrmt
		\setcounter{section}{0}%
		\setcounter{subsection}{0}%
		\gdef\thesection{\@Alph\c@section}%
	}%
	{%
		\setcounter{secnumdepth}{0}%
		\setcounter{section}{0}%
		\setcounter{subsection}{0}%
		\gdef\thesection{\@arabic\c@section}%
	}%

% Appendixes: remove \appendix command
\def\appendix{\@empty}


% Endnotes: Notes heading formatted as \section*
\if@endnotesformat
	\renewcommand{\enoteheading}{%
		\section*{\notesname}%
		\markboth{\notesname}{\notesname}%
		\addcontentsline{toc}{section}{\notesname}%
		\vspace{\dimexpr -4\tf@singlelineskip +1\baselineskip \relax}
		\singlespacing\mbox{}%
		\def\tf@adjaftersec{\dimexpr \tf@singlelineskip -\p@ \relax}
		\let\tf@afterindent\@afterindenttrue}%
\fi


