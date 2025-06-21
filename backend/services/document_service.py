import os
import google.generativeai as genai
from dotenv import load_dotenv
from datetime import date
import json

# Load environment variables from .env file
load_dotenv()

class DocumentService:
    def __init__(self):
        """Initialize document service and configure Gemini"""
        try:
            genai.configure(api_key=os.environ["GEMINI_API_KEY"])
            self.gen_model = genai.GenerativeModel('gemini-1.5-pro')
        except Exception as e:
            raise RuntimeError("GEMINI_API_KEY environment variable not set.") from e

    def generate_draft(self, analysis_response, case_id):
        """Generate a legal draft using Gemini based on the analysis results"""
        
        # Extract arguments and references
        strengths = analysis_response.strengths
        weaknesses = analysis_response.weaknesses

        # Prepare case references and arguments for Gemini
        strength_texts = []
        for arg in strengths:
            refs = [f"{ref.title} ({ref.caseIdentifier})" for ref in arg.case_references]
            strength_texts.append({
                'argument': arg.argument,
                'references': refs
            })

        weakness_texts = []
        for arg in weaknesses:
            refs = [f"{ref.title} ({ref.caseIdentifier})" for ref in arg.case_references]
            weakness_texts.append({
                'argument': arg.argument,
                'references': refs
            })

        # Create prompt for Gemini
        prompt = f"""
You are a legal expert tasked with drafting a formal legal document. Using the provided arguments and case references,
generate a well-structured legal document that presents the case in a professional and compelling manner.

Strengths/Arguments:
{self._format_arguments(strength_texts)}

Potential Weaknesses/Counterarguments:
{self._format_arguments(weakness_texts)}

Generate a JSON response with the following structure:
{{
    "claimants": "A professional description of the claimants",
    "respondents": "A professional description of the respondents",
    "title": "An appropriate title for this legal document",
    "intro_statement": "A clear introductory statement about the case",
    "body": "A well-structured main body of the document that:
            1. Presents the arguments in a logical order
            2. Cites relevant cases appropriately
            3. Addresses potential counterarguments
            4. Uses formal legal language
            5. Maintains professional tone throughout"
}}

The response should be a valid JSON object. The body should be properly formatted with HTML paragraphs (<p>) and headings (<h4>) where appropriate.
"""

        try:
            response = self.gen_model.generate_content(prompt)
            # Clean up potential markdown and parse
            cleaned_response = response.text.strip().replace("```json", "").replace("```", "")
            content = json.loads(cleaned_response)

            # Generate the final HTML document
            html_template = self._get_html_template()
            return html_template.format(
                claimants=content.get('claimants', f"Claimants (Case: {case_id})"),
                respondents=content.get('respondents', "Respondents"),
                title=content.get('title', "Legal Submission"),
                intro_statement=content.get('intro_statement', ""),
                body=content.get('body', ""),
                date=date.today().strftime("%d %B %Y")
            )

        except Exception as e:
            print(f"Error generating document with Gemini: {e}")
            return self._get_error_document(case_id)

    def _format_arguments(self, arguments):
        """Format arguments for the prompt"""
        formatted = []
        for i, arg in enumerate(arguments, 1):
            formatted.append(f"{i}. Argument: {arg['argument']}")
            formatted.append(f"   Supporting Cases: {', '.join(arg['references'])}")
        return "\n".join(formatted)

    def _get_html_template(self):
        """Return the HTML template for the document"""
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
        <meta charset="UTF-8">
        <title>Legal Submission</title>
        <style>
            body {{
                font-family: "Times New Roman", serif;
                margin: 40px;
                line-height: 1.6;
                color: #333;
            }}
            .center {{
                text-align: center;
            }}
            .underline {{
                text-decoration: underline;
            }}
            .italic {{
                font-style: italic;
            }}
            .bold {{
                font-weight: bold;
            }}
            .section-title {{
                margin-top: 2em;
                color: #2c3e50;
            }}
            blockquote {{
                margin-left: 2em;
                font-style: italic;
                color: #666;
                border-left: 3px solid #ccc;
                padding-left: 1em;
            }}
            h4 {{
                color: #2c3e50;
                margin-top: 1.5em;
            }}
            p {{
                margin-bottom: 1em;
                text-align: justify;
            }}
            .signature-section {{
                margin-top: 3em;
                border-top: 1px solid #ccc;
                padding-top: 1em;
            }}
        </style>
        </head>
        <body>

        <p class="center bold underline">IN THE MATTER OF THE ARBITRATION ACT 1996</p>
        <p class="center bold underline">AND IN THE MATTER OF AN ARBITRATION</p>

        <p class="center bold">BETWEEN:</p>

        <p class="center bold">{claimants}<br><span class="italic">Claimants</span></p>

        <p class="center bold">-and-</p>

        <p class="center bold">{respondents}<br><span class="italic">Respondents</span></p>

        <p class="center bold italic">{title}</p>

        <hr>

        <p class="center bold">LEGAL SUBMISSION</p>

        <hr>

        <div class="section-title">
            <h3>Introduction</h3>
        </div>

        <p>{intro_statement}</p>

        <div class="main-content">
            {body}
        </div>

        <div class="signature-section">
            <p><strong>Date:</strong> {date}</p>
            <p><strong>Signature:</strong> _____________________________</p>
        </div>

        </body>
        </html>
        """

    def _get_error_document(self, case_id):
        """Return a basic error document if generation fails"""
        return self._get_html_template().format(
            claimants=f"Claimants (Case: {case_id})",
            respondents="Respondents",
            title="Legal Submission",
            intro_statement="An error occurred while generating the document.",
            body="<p>The document could not be generated. Please try again later.</p>",
            date=date.today().strftime("%d %B %Y")
        ) 