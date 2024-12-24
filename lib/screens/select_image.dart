import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'ChatbotPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite/tflite.dart';
class DiseaseDetectionScreen extends StatefulWidget {
  @override
  _DiseaseDetectionScreenState createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  File? _image;

  String _output = "No classification yet.";
  bool _loading = false;
  late ImagePicker _picker = ImagePicker();
 late  ImageLabelerOptions options = ImageLabelerOptions(confidenceThreshold: 0.5);
 late  ImageLabeler imageLabeler = ImageLabeler(options: options);


  @override
  void initState() {
    super.initState();
    _loadModel();
  }
  Future<void> _loadModel() async {
    String? res = await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
    );
    print("Model loaded: $res");
  }

  Future<void> _classifyImage(File image) async {
    var result = await Tflite.runModelOnImage(
      path: image.path,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 5, // Number of top predictions to return
      threshold: 0.5, // Confidence threshold
    );

    setState(() {
      if (result != null && result.isNotEmpty) {
        _output = result.map((res) => "${res['label']} (${(res['confidence'] * 100).toStringAsFixed(2)}%)").join("\n");
      } else {
        _output = "No recognizable objects detected.";
      }
      _loading = false;
    });
  }
  // Function to pick image from the camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        performImageLabeling();
        _loading=true;
      });
      await _classifyImage(_image!);
    }
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  String result = "";
  performImageLabeling() async {
    result="";
    final inputImage = InputImage.fromFile(_image!);

    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

    for (ImageLabel label in labels) {
      final String text = label.label;
      final int index = label.index;
      final double confidence = label.confidence;
      print(text+"  "+confidence.toString());
      if(confidence*100>60){
        result+=text+"  "+(confidence*100).toStringAsFixed(2)+" "+"%"+"  "+"Accuracy"+"\n";
      }

    }
    setState(() {
      result;
    });
  }
  // Show search history in a bottom sheet
  void _showHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('search_history') ?? [];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: history.isEmpty
              ? Center(child: Text("No previous searches."))
              : ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(history[index]),
              );
            },
          ),
        );
      },
    );
  }

  // Logout user
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all saved preferences
    Navigator.pushReplacementNamed(context, '/sign_in'); // Redirect to login
  }

  // Show basic details about sugarcane
  void _showSugarcaneInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Sugarcane: A Giant Grass Full of Sugar"),
          content: Text(
              "Sugarcane is a tropical grass grown in warm climates. It is a major source of sugar and biofuel, providing significant economic value.Sugarcane, a giant tropical grass from the Graminaceae family, is renowned for its stalk's unique ability to store sucrose, a crystallizable sugar. It plays a significant role in industrial processes, particularly for rum production. Beyond its sugar content, sugarcane's impressive biomass is a valuable resource for energy production, including combustible materials, charcoal, biofuels, and chemical industry applications."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  // Show details about common sugarcane diseases
  void _showDiseasesInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Common Sugarcane Diseases"),
          content: Text(
              "1. Red Rot: A fungal disease causing reddish discoloration.\n\n"
                  "2. Smut: Identified by black whip-like structures on the stalk.\n\n"
                  "3. Grassy Shoot: A viral disease causing profuse tillering.\n\n"
                  "4. Leaf Scald: A bacterial disease causing white stripes on leaves."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
  void _showClimateInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Uses of Cane"),
          content: Text(
              "1.Temperature: Sugarcane requires warm temperatures, ideally between 20°C to 32°C (68°F to 90°F). Growth slows down if temperatures drop below 15°C (59°F) or rise above 38°C (100°F).\n\n"
                  "2.Rainfall: It requires moderate to high rainfall ranging from 1,000 mm to 2,500 mm per year, depending on the region. While sugarcane can tolerate periods of drought, it needs ample water, especially during the growing season, to achieve high yields.\n\n"
                  "3.Sunlight: Sugarcane is a sun-loving plant that requires full sunlight for optimum growth and high sugar production. It performs best in areas with long, sunny days.\n\n"
                  "4. Humidity: Humid environments are favorable for sugarcane, as the plant thrives in moisture-rich conditions, though it can also grow in slightly drier regions if irrigation is provided.\n\n"
                  "5.Frost-Free: Sugarcane cannot tolerate frost. A frost-free growing season is essential for successful cultivation.\n"
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
  void _showUsesInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Uses of Cane"),
          content: Text(
              "1.Sugar Production: The primary use of sugarcane is for extracting sucrose, which is processed into sugar for food and beverages.\n"
                  "2.Rum Production: Sugarcane is essential in the production of rum and other alcoholic beverages through fermentation.\n"
                  "3.Biofuels: The plant's biomass, including stalks and leaves, can be converted into biofuels such as ethanol, providing an alternative energy source.\n"
                  "4. Chemicals and Green Materials: Sugarcane provides cellulose and lignin, which are used in the production of green chemicals, bioplastics, and other sustainable materials.\n"
                  "5.Paper and Packaging: The fibrous material from sugarcane is used to create paper, cardboard, and biodegradable packaging products.\n"
                  "6.Soil Conservation: Sugarcane’s deep root system helps prevent soil erosion, especially in tropical regions."
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showFAQs() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("FAQs about Sugarcane Farming"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("1. What is the best time to plant sugarcane?"),
                Text(
                    "Answer: Sugarcane is typically planted in the spring or early summer when temperatures are warm enough for healthy growth."),
                SizedBox(height: 10),
                Text("2. How often should sugarcane be watered?"),
                Text(
                    "Answer: Sugarcane requires regular watering during the growing season, with intervals depending on soil type and climate."),
                SizedBox(height: 10),
                Text("3. What are the common pests that affect sugarcane?"),
                Text(
                    "Answer: Common pests include root-feeding nematodes, white grubs, and sugarcane borers, which can damage the roots and stalks."),
                SizedBox(height: 10),
                Text("4. What diseases are common in sugarcane cultivation?"),
                Text(
                    "Answer: Common diseases include red rot, smut, grassy shoot, and leaf scald, each affecting different parts of the plant."),
                SizedBox(height: 10),
                Text("5. How can sugarcane yield be improved?"),
                Text(
                    "Answer: Use high-quality seeds, proper irrigation, pest and disease management, and balanced fertilizers to boost yield."),
                SizedBox(height: 10),
                Text("6. How long does it take for sugarcane to mature?"),
                Text(
                    "Answer: Sugarcane typically takes 12 to 18 months to mature, depending on the variety and climatic conditions."),
                SizedBox(height: 10),
                Text("7. What are the benefits of intercropping with sugarcane?"),
                Text(
                    "Answer: Intercropping with crops like legumes or vegetables improves soil fertility, reduces pest attacks, and increases overall farm productivity."),
                SizedBox(height: 10),
                Text("8. Can sugarcane tolerate drought?"),
                Text(
                    "Answer: Sugarcane is moderately drought-tolerant, but prolonged drought can significantly reduce yield and sugar content."),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showCropManagementTips() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Crop Management Tips for Sugarcane Farming"),
          content: SingleChildScrollView(
            child: Text(
                "1. Soil Preparation: Ensure proper tillage and leveling of the soil to promote good water distribution and root development.\n\n"
                    "2. Seed Selection: Use high-yielding, disease-resistant sugarcane varieties suitable for your region.\n\n"
                    "3. Fertilization: Apply balanced fertilizers based on soil testing to meet the crop's nutrient requirements.\n\n"
                    "4. Irrigation: Schedule irrigation to maintain optimal soil moisture, especially during critical growth stages. Avoid waterlogging.\n\n"
                    "5. Weed Control: Regularly remove weeds manually or use appropriate herbicides to minimize competition for nutrients.\n\n"
                    "6. Pest and Disease Management: Monitor crops regularly and apply biological or chemical controls as needed to manage pests and diseases effectively.\n\n"
                    "7. Intercropping: Consider intercropping with legumes or vegetables to improve soil fertility and overall farm productivity.\n\n"
                    "8. Harvesting: Harvest at the correct maturity stage to maximize sugar content. Avoid delays to prevent sucrose loss.\n\n"
                    "9. Post-Harvest Care: Properly store and process harvested sugarcane to maintain quality and prevent spoilage."),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }


  void _showRealTimeAnalysis() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Real-Time Analysis: Match Your Leaf"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/images/redrot.jpeg"),
                SizedBox(height: 10),
                Text(
                    "1. Mosaic Disease\n"
                        "Cause: Viral infection caused by the Sugarcane Mosaic Virus (SCMV).\n\n"
                        "Symptoms:\n"
                        "Mottling or mosaic patterns on the leaves, with alternating green and yellow patches."
                        " Stunted growth and reduced tillering."
                        " Weak, thin stalks leading to lower yield.\n\n"
                        "Control Measures:\n"
                        "Plant virus-free seed material."
                        " Eliminate infected plants from the field."
                        " Control aphids and other pests that act as vectors for the virus."
                        " Use tolerant or resistant sugarcane varieties."
                ),

                Image.asset("assets/images/mosaic.jpeg"),
                SizedBox(height: 10),
                Text(
                    "2. Mosaic Disease\n"
                        "Cause: Viral infection caused by the Sugarcane Mosaic Virus (SCMV).\n\n"
                        "Symptoms:\n"
                        "Mottling or mosaic patterns on the leaves, with alternating green and yellow patches."
                        " Stunted growth and reduced tillering."
                        " Weak, thin stalks leading to lower yield.\n\n"
                        "Control Measures:\n"
                        "Plant virus-free seed material."
                        " Eliminate infected plants from the field."
                        " Control aphids and other pests that act as vectors for the virus."
                        " Use tolerant or resistant sugarcane varieties."
                ),

                SizedBox(height: 20),
                Image.asset("assets/images/yellow.jpeg"),
                SizedBox(height: 10),
                Text(
                    "3. Yellow Leaf Disease\n"
                        "Cause: Viral infection caused by the Sugarcane Yellow Leaf Virus (ScYLV).\n\n"
                        "Symptoms:\n"
                        "Yellowing of the midrib, starting from the lower leaves and progressing upwards."
                        " General yellowing of the leaf blades in severe cases."
                        " Stunted growth and reduced sugar content in stalks.\n\n"
                        "Control Measures:\n"
                        "Use clean planting material from certified sources."
                        " Monitor fields regularly for signs of the disease."
                        " Remove and destroy infected plants."
                ),

                SizedBox(height: 20),
                Image.asset("assets/images/rust.jpeg"),
                SizedBox(height: 10),
                Text("4. Rust\n"
                    "Cause: Fungal infection caused by Puccinia melanocephala.\n\n"
                    "Symptoms\n"
                    "Small, elongated, and reddish-brown lesions appear on leaves."
                    "These lesions eventually form pustules that release rust-colored spores."
                    "Affected leaves may dry out prematurely, reducing photosynthesis and yield.\n\n"
                    "Control Measures:\n"
                    "Use rust-resistant sugarcane varieties."
                    "Apply fungicides as recommended during the early stages of infection."
                    "Practice crop rotation and destroy infected plant residues."),
                SizedBox(height: 20),
                Image.asset("assets/images/healthy.jpeg"),
                SizedBox(height: 10),
                Text("5.It is a helthy sugarcane plant."),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sugarcane Disease Detection",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade900,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green.shade900,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Search History'),
              onTap: _showHistory,
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('Sugarcane'),
              onTap: _showSugarcaneInfo,
            ),
            ListTile(
              leading: Icon(Icons.bug_report),
              title: Text('Diseases'),
              onTap: _showDiseasesInfo,
            ),
            ListTile(
              leading: Icon(Icons.bug_report),
              title: Text('Uses'),
              onTap: _showUsesInfo,
            ),
            ListTile(
              leading: Icon(Icons.bug_report),
              title: Text('Suitable Climate'),
              onTap: _showClimateInfo,
            ),
            ListTile(
              leading: Icon(Icons.agriculture),
              title: Text('Crop Management Tips'),
              onTap: _showCropManagementTips,
            ),
            ListTile(
              leading: Icon(Icons.image_search),
              title: Text('Real-Time Analysis'),
              onTap: _showRealTimeAnalysis,
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Flexible(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, Colors.black54, Colors.black12],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        "Upload a leaf image",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      SizedBox(height: 20),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: Icon(Icons.camera),
                            label: Text(
                              "Capture Image",
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: Icon(Icons.image),
                            label: Text(
                              "Select from Gallery",
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 2,
                        child: _image != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            _image!,
                            height: 200,
                            width: 300,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Container(
                          height: 200,
                          width: 300,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text("No Image Selected"),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatbotPage(
                                selectedImage: _image,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "Proceed",
                          style: TextStyle(
                              color: Colors.black54, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Flexible(
                        child: Card(
                          color: Colors.white10,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.all(10),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Text(
                                result,
                                style: TextStyle(fontSize: 18, color: Colors.black,fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          margin: EdgeInsets.all(10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.green.shade900,
            onPressed: _showFAQs,
            heroTag: "faqButton", // Unique heroTag
            child: Icon(Icons.question_answer),
          ),
          SizedBox(height: 10), // Spacing between buttons
          FloatingActionButton(
            backgroundColor: Colors.green.shade900,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatbotPage()),
              );
            },
            heroTag: "chatbotButton", // Unique heroTag
            child: Icon(Icons.help),
          ),
        ],
      ),
    );
  }
}

