\ProvidesClass{twentysecondcv}[2015/02/28 CV class]
\LoadClass{article}
\NeedsTeXFormat{LaTeX2e}

%----------------------------------------------------------------------------------------
%	 REQUIRED PACKAGES
%-----------------------------------------------------------------------	-----------------

\RequirePackage[quiet]{fontspec}
\RequirePackage[sfdefault]{ClearSans}

\def\arrow#1{\pspicture[shift=2pt](#1,0)\psline{->}(#1,0)\endpspicture}

\usepackage{pstricks}

\usepackage{fontawesome}
\RequirePackage{tikz}
\RequirePackage{xcolor}
\RequirePackage[absolute,overlay]{textpos}
\RequirePackage{ragged2e}
\RequirePackage{etoolbox}
\RequirePackage{ifmtarg}
\RequirePackage{ifthen}
\RequirePackage{pgffor}
\RequirePackage{marvosym}
\RequirePackage{parskip}
\usepackage{setspace}

\usepackage{enumitem}
\setlist[itemize]{leftmargin=*}

\RequirePackage[hidelinks]{hyperref}
\hypersetup{
  pdftitle={CV Maciej Procyk},
  pdfauthor={Maciej Procyk},
  pdfsubject={CV},
  pdfkeywords={cv, software, developer, maciej, procyk},
  colorlinks=false,           % no lik border color
  allbordercolors=white       % white border color for all
}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax

\ifxetex
\usepackage{letltxmacro}
\setlength{\XeTeXLinkMargin}{1pt}
\LetLtxMacro\SavedIncludeGraphics\includegraphics
\def\includegraphics#1#{% #1 catches optional stuff (star/opt. arg.)
  \IncludeGraphicsAux{#1}%
}%
\newcommand*{\IncludeGraphicsAux}[2]{%
  \XeTeXLinkBox{%
    \SavedIncludeGraphics#1{#2}%
  }%
}%
\fi

%----------------------------------------------------------------------------------------
%	 COLOURS
%----------------------------------------------------------------------------------------

\definecolor{white}{RGB}{255,255,255}
\definecolor{gray}{HTML}{4D4D4D}
\definecolor{sidecolor}{HTML}{E7E7E7}
\definecolor{mainblue}{HTML}{0E5484}
\definecolor{maingray}{HTML}{B9B9B9}

\definecolor{pblue}{HTML}{0395DE}

\definecolor{darkgray}{HTML}{333333}
\definecolor{gray}{HTML}{4D4D4D}
\definecolor{lightgray}{HTML}{999999}
\definecolor{green}{HTML}{C2E15F}
\definecolor{orange}{HTML}{FDA333}
\definecolor{purple}{HTML}{D3A4F9}
\definecolor{red}{HTML}{FB4485}
\definecolor{blue}{HTML}{6CE0F1}
\definecolor{pblue}{HTML}{0395DE}
\definecolor{materialpurple}{HTML}{9C27B0}
\definecolor{materialindigo}{HTML}{3F51B5}
\definecolor{materialblue}{HTML}{2196F3}
\definecolor{materialcyan}{HTML}{00BCD4}
\definecolor{materialteal}{HTML}{009688}
\definecolor{materialgreen}{HTML}{4CAF50}
\definecolor{materiallime}{HTML}{CDDC39}
\definecolor{materialamber}{HTML}{FFC107}
\definecolor{materialbrown}{HTML}{795548}
\definecolor{materialred}{HTML}{FF4436}
\definecolor{materialorange}{HTML}{FF5722}
\definecolor{linkedin}{HTML}{0085AE}
\definecolor{gitlab}{HTML}{F48406}
\definecolor{github}{HTML}{000000}
\definecolor{test}{HTML}{0077be}
\definecolor{yt}{HTML}{c71610}

\ifdefined\@cv@print
\colorlet{green}{gray}
\colorlet{orange}{gray}
\colorlet{purple}{gray}
\colorlet{red}{gray}
\colorlet{blue}{gray}
\colorlet{fillheader}{white}
\colorlet{header}{gray}
\else
\colorlet{fillheader}{white}
\colorlet{header}{gray}
\fi
\colorlet{textcolor}{gray}
\colorlet{headercolor}{gray}

%----------------------------------------------------------------------------------------
%	 MISC CONFIGURATIONS
%----------------------------------------------------------------------------------------

% \renewcommand{\bfseries}{\color{black}} % Make \textbf produce coloured text instead

\pagestyle{empty} % Disable headers and footers

\setlength{\parindent}{0pt} % Disable paragraph indentation

% --------------------------------------------------------------------------------------
% 	FONTS
%-------------------------------------------------------------------------------------
\newfontfamily\headingfont[Path = fonts/]{segoeuib.ttf}

%----------------------------------------------------------------------------------------
%	 SIDEBAR DEFINITIONS
%----------------------------------------------------------------------------------------

\setlength{\TPHorizModule}{1cm} % Left margin
\setlength{\TPVertModule}{1cm} % Top margin

\newlength\imagewidth
\newlength\imagescale
\pgfmathsetlength{\imagewidth}{5cm}
\pgfmathsetlength{\imagescale}{\imagewidth/600}

\newcommand{\profilesection}[2]{\vspace{5pt}{\color{black!80} \large #1 \rule[0.15\baselineskip]{#2}{1pt}}}

% Define custom commands for CV info
\newcommand{\cvdate}[1]{\renewcommand{\cvdate}{#1}}
\newcommand{\cvlinkedin}[1]{\renewcommand{\cvlinkedin}{#1}}
\newcommand{\cvgithub}[1]{\renewcommand{\cvgithub}{#1}}
\newcommand{\cvgitlab}[1]{\renewcommand{\cvgitlab}{#1}}
\newcommand{\cvmail}[1]{\renewcommand{\cvmail}{#1}}
\newcommand{\cvnumberphone}[1]{\renewcommand{\cvnumberphone}{#1}}
\newcommand{\cvaddress}[1]{\renewcommand{\cvaddress}{#1}}
\newcommand{\cvsite}[1]{\renewcommand{\cvsite}{#1}}
\newcommand{\aboutme}[1]{\renewcommand{\aboutme}{#1}}
\newcommand{\profilepic}[1]{\renewcommand{\profilepic}{#1}}
\newcommand{\cvname}[1]{\renewcommand{\cvname}{#1}}
\newcommand{\cvjobtitle}[1]{\renewcommand{\cvjobtitle}{#1}}

% Command for printing the contact information icons
\newcommand*\icon[1]{\tikz[baseline=(char.base)]{\node[shape=circle,draw,inner sep=1pt, fill=mainblue,mainblue,text=white] (char) {#1};}}

% Command for printing skill progress bars
\newcommand\programming[1]{
  \renewcommand{\programming}{
    \begin{tikzpicture}
      %\node [above right] at (0, 4) {$0 \: LOC \: \arrow{3.2} \: 5000 \: LOC$};
      \foreach [count=\i] \x/\y in {#1}{
        \draw[fill=maingray,maingray] (0,\i) rectangle (6,\i+0.4);
        \draw[fill=white,mainblue](0,\i) rectangle (\y,\i+0.4);
        \node [above right] at (0,\i+0.35) {\x};
      }
    \end{tikzpicture}
  }
}
\newcommand\education[1]{
  \renewcommand{\education}{
      {#1}
  }
}

\newcommand\otherthings[1]{
  \renewcommand{\otherthings}{
      {#1}
  }
}

%----------------------------------------------------------------------------------------
%  SIDEBAR LAYOUT
%----------------------------------------------------------------------------------------

\newcommand{\makeprofile}{
  \begin{tikzpicture}[remember picture,overlay]
    \node [rectangle, fill=sidecolor, anchor=north, minimum width=9cm, minimum height=\paperheight+1cm] (box) at (-5cm,0.5cm){};
  \end{tikzpicture}

%------------------------------------------------

  \begin{textblock}{6}(0.5, 0.2)

    %------------------------------------------------

    \vspace{4mm}
    {\Huge\color{pblue}\cvname}

    \vspace{2mm}

    %------------------------------------------------

    {\Large\color{black!80}\cvjobtitle}

    %------------------------------------------------

    \vspace{3mm}
    \renewcommand{\arraystretch}{2}
    \begin{tabular}{p{1cm} @{\hskip 0.5cm}p{5cm}}
      \ifthenelse{\equal{\cvnumberphone}{}}{}{
          {$
        \begin{array}{l}
          \hspace{4mm} \Huge \textnormal{\faMobile}
        \end{array}
        $}
        & \cvnumberphone                                        \\}

      \ifthenelse{\equal{\cvsite}{}}{}{
          {$
        \begin{array}{l}
          \hspace{2.8mm} \huge \textnormal{\textcolor{test}{\faGlobe}}
        \end{array}
        $}
        & \href{\cvsite}{\cvsite}                        \\}
      \ifthenelse{\equal{\cvmail}{}}{}{
          {$
        \begin{array}{l}
          \hspace{2.5mm} \huge \textnormal{\textcolor{yt}{\faEnvelopeO}}
        \end{array}
        $}
        & \href{mailto:\cvmail}{\cvmail}                        \\}

      \ifthenelse{\equal{\cvlinkedin}{}}{}{
          {$
        \begin{array}{l}
          \hspace{3mm} \huge \textnormal{\textcolor{linkedin}{\faLinkedin}}
        \end{array}
        $} & \href{https://www.linkedin.com\cvlinkedin}{\cvlinkedin} \\
      }
      \ifthenelse{\equal{\cvgithub}{}}{}{
          {$
        \begin{array}{l}
          \hspace{3mm} \huge \textnormal{\textcolor{github} \faGithub}
        \end{array}
        $} & \href{https://www.github.com\cvgithub}{\cvgithub}     \\
      }
      \ifthenelse{\equal{\cvgitlab}{}}{}{
          {$
        \begin{array}{l}
          \hspace{3mm} \huge \textnormal{\textcolor{gitlab} \faGitlab}
        \end{array}
        $} & \href{https://www.gitlab.com\cvgitlab}{\cvgitlab}     \\
      }

    \end{tabular}

    %------------------------------------------------
    \vspace{1mm}
    \profilesection{Technical Skills}{29mm}

    \vspace{1mm}
    {\large\textbf{Overview}}

    \skills

    %------------------------------------------------

    \vspace{3mm}

    {\large \textbf{Programming}}

    \programming

    \vspace{1mm}
    \profilesection{Education}{38mm}

    \education

    \profilesection{Other}{47mm}

    \otherthings

    \vspace{0.45cm}
    \begin{tiny}
      \begin{spacing}{0.1}
        I agree to the processing of personal data provided in this document for realising the recruitment process pursuant to the Personal Data Protection Act of 10 May 2018 (Journal of Laws 2018, item 1000) and in agreement with Regulation (EU) 2016/679 of the European Parliament and of the Council of 27 April 2016 on the protection of natural persons with regard to the processing of personal data and on the free movement of such data, and repealing Directive 95/46/EC (General Data Protection Regulation)
      \end{spacing}
    \end{tiny}

  \end{textblock}
}


%----------------------------------------------------------------------------------------
%	 COLOURED SECTION TITLE BOX
%----------------------------------------------------------------------------------------

% Command to create the rounded boxes around the first three letters of section titles
\newcommand*\round[2]{%
  \tikz[baseline=(char.base)]\node[anchor=north west, draw,rectangle, rounded corners, inner sep=1.6pt, minimum size=5.5mm, text height=3.6mm, fill=#2,#2,text=white](char){#1};%
}

\def\@sectioncolor#1#2#3{%
    {%
    \color{pblue} #1#2#3%
  }%
}


\renewcommand{\section}[1]{
  \par\vspace{\parskip}
  {%
    \Large\headingfont\color{headercolor}%
    \@sectioncolor #1%
  }
  \par\vspace{1mm}
}

\renewcommand{\subsection}[1]{
  \par\vspace{.5\parskip}{%
    \large\headingfont\color{headercolor} #1%
  }
  \par\vspace{.25\parskip}%
}

\pagestyle{empty}

%----------------------------------------------------------------------------------------
%	 LONG LIST ENVIRONMENT
%----------------------------------------------------------------------------------------

\setlength{\tabcolsep}{0pt}

% New environment for the long list
\newenvironment{twenty}{%
  \begin{tabular*}{\textwidth}{@{\extracolsep{\fill}}ll}
  }{%
  \end{tabular*}
}

% \newcommand{\twentyitem}[5]{%
% 	#1&\parbox[t]{0.83\textwidth}{%
% 		\textbf{#2}%
% 		\hfill%
% 		{\footnotesize#3}\\%
%         \ifblank{#4}{}{#4 \\}
% 		#5\vspace{\parsep}%
% 	}\\
% }

\newcommand{\twentyitem}[6]{%
  \parbox[t]{1.03\textwidth}{%
    \textbf{#3} \hfill {\footnotesize#4 (\ifblank{#2}{#1}{#1 - #2})}
  }\\
  \parbox[t]{1.03\textwidth}{
    \ifblank{#5}{}{#5 \\}\vspace{-0.15cm}
    #6%
  }\\
}

%----------------------------------------------------------------------------------------
%	 SMALL LIST ENVIRONMENT
%----------------------------------------------------------------------------------------

\setlength{\tabcolsep}{0pt}

% New environment for the small list
\newenvironment{twentyshort}{%
  \begin{tabular*}{\textwidth}{@{\extracolsep{\fill}}ll}
  }{%
  \end{tabular*}
}

\newcommand{\twentyitemshort}[2]{%
  #1&\parbox[t]{0.83\textwidth}{%
    #2%
  }\\
}

%----------------------------------------------------------------------------------------
%	 MARGINS AND LINKS
%----------------------------------------------------------------------------------------

\RequirePackage[left=7.6cm,top=0.1cm,right=1cm,bottom=0.1cm,nohead,nofoot]{geometry}


\usepackage{smartdiagram}
\smartdiagramset{
  bubble center node font = \footnotesize,
  bubble node font = \footnotesize,
% specifies the minimum size of the bubble center node
  bubble center node size = 0.5cm,
%  specifies the minimum size of the bubbles
  bubble node size = 0.5cm,
% specifies which is the distance among the bubble center node and the other bubbles
  distance center/other bubbles = 0.4cm,
% sets the distance from the text to the border of the bubble center node
  distance text center bubble = 0.5cm,
% set center bubble color
  bubble center node color = pblue,
% define the list of colors usable in the diagram
  set color list = {lightgray, materialcyan, orange, green, materialorange, materialteal, materialamber, materialindigo, materialgreen, materiallime},
% sets the opacity at which the bubbles are shown
  bubble fill opacity = 0.6,
% sets the opacity at which the bubble text is shown
  bubble text opacity = 1,
}

