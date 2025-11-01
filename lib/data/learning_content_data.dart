import '../models/learning_content_model.dart';

/// Data source for learning content (videos and articles)
/// TODO: Replace with API calls to backend/Supabase
class LearningContentData {
  
  // ========================================
  // VIDEO CONTENT
  // ========================================
  
  static final List<LearningContent> videos = [
    LearningContent(
      id: 'v1',
      title: 'How to Safely Dispose of Old Smartphones',
      description: 'Learn the proper steps to prepare and dispose of your smartphone, including data wiping, battery care, and finding certified disposal centers.',
      type: ContentType.video,
      category: ContentCategory.smartphone,
      thumbnailUrl: 'lib/assets/images/apple-ip.jpg',
      videoUrl: 'https://youtube.com/watch?v=example1', // TODO: Replace with real URL
      duration: const Duration(minutes: 5, seconds: 30),
      author: 'TechSustain Team',
      publishedDate: DateTime.now().subtract(const Duration(days: 7)),
      tags: ['smartphone', 'disposal', 'data-security', 'beginner'],
      views: 12500,
      isFeatured: true,
    ),
    LearningContent(
      id: 'v2',
      title: 'Laptop Refurbishing: Step-by-Step Tutorial',
      description: 'Transform your old laptop into a usable device. This comprehensive guide covers cleaning, hardware upgrades, OS installation, and performance optimization.',
      type: ContentType.video,
      category: ContentCategory.laptop,
      thumbnailUrl: 'lib/assets/images/macbook.jpg',
      videoUrl: 'https://youtube.com/watch?v=example2',
      duration: const Duration(minutes: 12, seconds: 15),
      author: 'Green Tech Guide',
      publishedDate: DateTime.now().subtract(const Duration(days: 3)),
      tags: ['laptop', 'refurbish', 'reuse', 'tutorial'],
      views: 8340,
      isFeatured: true,
    ),
    LearningContent(
      id: 'v3',
      title: 'Battery Disposal: What You Need to Know',
      description: 'Batteries contain hazardous materials. Learn how to identify battery types, store them safely, and find proper disposal locations.',
      type: ContentType.video,
      category: ContentCategory.batteries,
      thumbnailUrl: null,
      videoUrl: 'https://youtube.com/watch?v=example3',
      duration: const Duration(minutes: 4, seconds: 45),
      author: 'Eco Warriors',
      publishedDate: DateTime.now().subtract(const Duration(days: 14)),
      tags: ['batteries', 'safety', 'disposal', 'environment'],
      views: 5200,
      isFeatured: false,
    ),
    LearningContent(
      id: 'v4',
      title: 'Tablet Repair vs Disposal: Making the Right Choice',
      description: 'Should you repair or dispose of your broken tablet? This guide helps you decide based on age, damage, and cost-effectiveness.',
      type: ContentType.video,
      category: ContentCategory.tablet,
      thumbnailUrl: 'lib/assets/images/ipad.jpg',
      videoUrl: 'https://youtube.com/watch?v=example4',
      duration: const Duration(minutes: 6, seconds: 20),
      author: 'Device Doctor',
      publishedDate: DateTime.now().subtract(const Duration(days: 21)),
      tags: ['tablet', 'repair', 'disposal', 'decision-guide'],
      views: 3890,
      isFeatured: false,
    ),
    LearningContent(
      id: 'v5',
      title: 'Cable and Charger Disposal: Best Practices',
      description: 'Old cables and chargers pile up fast. Learn how to properly sort, test, and dispose of electronic accessories responsibly.',
      type: ContentType.video,
      category: ContentCategory.chargers,
      thumbnailUrl: 'lib/assets/images/charger.jpg',
      videoUrl: 'https://youtube.com/watch?v=example5',
      duration: const Duration(minutes: 3, seconds: 50),
      author: 'TechSustain Team',
      publishedDate: DateTime.now().subtract(const Duration(days: 10)),
      tags: ['cables', 'chargers', 'accessories', 'disposal'],
      views: 6120,
      isFeatured: false,
    ),
  ];

  // ========================================
  // ARTICLE CONTENT
  // ========================================
  
  static final List<LearningContent> articles = [
    LearningContent(
      id: 'a1',
      title: 'The Complete Guide to E-Waste Disposal',
      description: 'Everything you need to know about disposing of electronic waste safely and responsibly.',
      type: ContentType.article,
      category: ContentCategory.general,
      thumbnailUrl: 'lib/assets/images/ewaste.png',
      articleContent: _ewasteDisposalArticle,
      author: 'Sarah Chen',
      publishedDate: DateTime.now().subtract(const Duration(days: 5)),
      tags: ['e-waste', 'disposal', 'environment', 'guide'],
      views: 15600,
      isFeatured: true,
    ),
    LearningContent(
      id: 'a2',
      title: 'How to Prepare Your Smartphone for Disposal',
      description: 'A detailed checklist to ensure your phone is ready for safe disposal or donation.',
      type: ContentType.article,
      category: ContentCategory.smartphone,
      thumbnailUrl: 'lib/assets/images/phone.png',
      articleContent: _smartphonePreparationArticle,
      author: 'Kert Abajo',
      publishedDate: DateTime.now().subtract(const Duration(days: 12)),
      tags: ['smartphone', 'preparation', 'data-security', 'checklist'],
      views: 9870,
      isFeatured: false,
    ),
    LearningContent(
      id: 'a3',
      title: 'Giving Old Laptops a Second Life',
      description: 'Creative ways to repurpose, donate, or refurbish your old laptop instead of disposing it.',
      type: ContentType.article,
      category: ContentCategory.laptop,
      thumbnailUrl: null,
      articleContent: _laptopSecondLifeArticle,
      author: 'Alex Johnson',
      publishedDate: DateTime.now().subtract(const Duration(days: 8)),
      tags: ['laptop', 'reuse', 'donation', 'refurbish'],
      views: 7230,
      isFeatured: false,
    ),
    LearningContent(
      id: 'a4',
      title: 'Understanding E-Waste Regulations in Your Area',
      description: 'Know your local laws and regulations regarding electronic waste disposal and compliance.',
      type: ContentType.article,
      category: ContentCategory.general,
      thumbnailUrl: null,
      articleContent: _ewasteRegulationsArticle,
      author: 'Legal Eagle',
      publishedDate: DateTime.now().subtract(const Duration(days: 30)),
      tags: ['regulations', 'legal', 'compliance', 'local-laws'],
      views: 4560,
      isFeatured: false,
    ),
    LearningContent(
      id: 'a5',
      title: 'What Happens After You Dispose Your Device?',
      description: 'Follow the journey of your old electronics from disposal center to material recovery.',
      type: ContentType.article,
      category: ContentCategory.general,
      thumbnailUrl: null,
      articleContent: _disposalJourneyArticle,
      author: 'Green Tech Guide',
      publishedDate: DateTime.now().subtract(const Duration(days: 18)),
      tags: ['disposal', 'process', 'materials', 'environment'],
      views: 11200,
      isFeatured: true,
    ),
  ];

  // ========================================
  // ARTICLE CONTENT (Rich Text)
  // ========================================
  
  static const String _ewasteDisposalArticle = '''
# The Complete Guide to E-Waste Disposal

Electronic waste, or e-waste, is one of the fastest-growing waste streams globally. Proper disposal is crucial for environmental protection and data security.

## Why E-Waste Disposal Matters

Electronic devices contain valuable materials like gold, silver, and copper, but also hazardous substances like lead, mercury, and cadmium. When disposed improperly, these toxins can contaminate soil and water.

## Steps for Proper Disposal

### 1. Back Up Your Data
Before disposing of any device, ensure all important data is backed up to cloud storage or an external drive.

### 2. Wipe All Personal Information
Perform a factory reset on smartphones and tablets. For computers, use data-wiping software to ensure files cannot be recovered.

### 3. Remove Batteries and SIM Cards
Take out removable batteries, SIM cards, and memory cards. These often need separate disposal methods.

### 4. Find a Certified Disposal Center
Look for e-waste facilities certified by recognized environmental organizations. They ensure proper handling and material recovery.

### 5. Consider Donation or Resale
If your device still works, consider donating it to schools, charities, or selling it through certified refurbishment programs.

## What NOT to Do

- ❌ Don't throw electronics in regular trash
- ❌ Don't burn electronic devices
- ❌ Don't dispose batteries with general waste
- ❌ Don't ship e-waste to uncertified facilities

## Finding Disposal Centers

Many retailers and manufacturers offer take-back programs. Check with:
- Local government waste management
- Electronics retailers
- Manufacturer take-back programs
- Certified e-waste facilities

## Environmental Impact

Proper e-waste disposal can:
- Prevent toxic materials from entering landfills
- Recover valuable metals for reuse
- Reduce the need for mining new materials
- Lower carbon emissions from manufacturing

Remember: Every device disposed responsibly makes a difference!
''';

  static const String _smartphonePreparationArticle = '''
# How to Prepare Your Smartphone for Disposal

Preparing your smartphone properly ensures your personal data stays safe and the device can be processed efficiently.

## Pre-Disposal Checklist

### Data Security
✓ Back up photos, contacts, and files to cloud storage
✓ Sign out of all accounts (Google, Apple, social media)
✓ Remove screen lock and passwords
✓ Perform factory reset
✓ Verify all data is erased

### Physical Preparation
✓ Remove SIM card
✓ Remove microSD card (if applicable)
✓ Remove phone case and screen protector
✓ Clean the device
✓ Check for physical damage

### Accessories
✓ Gather original charger
✓ Include original box (if available)
✓ Collect any earphones or cables
✓ Find warranty documents

## Factory Reset Guide

**For Android:**
1. Go to Settings > System > Reset
2. Select "Factory data reset"
3. Confirm and wait for completion
4. Verify by trying to access data

**For iPhone:**
1. Go to Settings > General > Reset
2. Select "Erase All Content and Settings"
3. Enter passcode
4. Confirm erasure

## After Reset

Once reset, your phone should:
- Show the initial setup screen
- Have no accounts linked
- Contain no personal files
- Be unlocked (no passcode)

## Battery Check

Before disposal, inspect the battery:
- Look for swelling or bulging
- Check for leaks or corrosion
- Note if battery is removable
- Inform disposal center of any issues

## Final Steps

With your phone prepared:
1. Take it to a certified disposal center
2. Ask for a disposal receipt
3. Request information on their process
4. Verify they won't resell your device

Your data security is just as important as environmental responsibility!
''';

  static const String _laptopSecondLifeArticle = '''
# Giving Old Laptops a Second Life

Before disposing of your laptop, consider these alternative options that extend its usefulness.

## Refurbishment Options

### Light Refresh
If your laptop is 3-5 years old:
- Upgrade RAM (4GB → 8GB or more)
- Replace HDD with SSD
- Install lightweight OS (Linux)
- Clean fans and apply thermal paste
- Replace worn keyboard/trackpad

### Full Refurbishment
For older laptops with good build quality:
- Replace battery
- Upgrade storage to 256GB+ SSD
- Max out RAM capacity
- Install modern OS
- Consider new display panel

## Donation Opportunities

### Schools and Libraries
Many educational institutions accept working laptops for student use. They often have IT staff to handle refurbishment.

### Non-Profit Organizations
Look for:
- Community centers
- Job training programs
- Senior centers
- Homeless shelters
- Women's shelters

### International Programs
Some organizations refurbish laptops and ship them to developing countries where they're desperately needed.

## Repurposing Ideas

### Home Server
Turn your old laptop into:
- Media server (Plex/Jellyfin)
- Home automation hub
- Network-attached storage (NAS)
- Ad blocker (Pi-hole)

### Dedicated Device
Use it as:
- Digital photo frame
- Kitchen recipe display
- Kids' learning computer
- Workshop/garage PC

### Learning Platform
Perfect for:
- Learning to code
- Testing new operating systems
- Cybersecurity practice
- Electronics tinkering

## Resale Options

### Where to Sell
- Certified refurbishers
- Online marketplaces (with honest description)
- Trade-in programs
- Local repair shops

### Pricing Guide
Consider age, specs, and condition:
- Working well: 20-40% of original price
- Needs minor repair: 10-20%
- Parts only: 5-10%

## When to Dispose

Dispose if your laptop:
- Has severe physical damage
- Costs more to repair than replace
- Contains obsolete components
- Has irreparable motherboard issues
- Has safety hazards (swollen battery)

Remember: One person's old laptop can be another person's opportunity!
''';

  static const String _ewasteRegulationsArticle = '''
# Understanding E-Waste Regulations in Your Area

E-waste disposal is regulated differently around the world. Knowing your local laws helps ensure compliance and environmental responsibility.

## Common Regulations

### Extended Producer Responsibility (EPR)
Manufacturers must:
- Take back old products
- Fund disposal programs
- Meet collection targets
- Report disposal data

### Consumer Requirements
Individuals must:
- Use designated disposal sites
- Separate e-waste from regular trash
- Pay disposal fees (in some regions)
- Follow specific preparation steps

## Regional Differences

### United States
- Regulations vary by state
- Some states ban landfill disposal
- Retailer take-back often required
- Federal regulations for businesses

### European Union
- WEEE Directive mandates proper disposal
- Free take-back at retailers
- Producer-funded programs
- Strict export controls

### Asia-Pacific
- Varies greatly by country
- Some have comprehensive laws
- Others are developing frameworks
- Growing enforcement

## Penalties for Non-Compliance

Improper disposal can result in:
- Fines (vary by jurisdiction)
- Legal liability
- Environmental damage fees
- Criminal charges (severe cases)

## How to Stay Compliant

1. **Know Your Local Laws**
   - Check municipal website
   - Call waste management office
   - Review state/province regulations

2. **Use Certified Facilities**
   - Verify certifications
   - Ask for documentation
   - Request disposal receipts

3. **Follow Guidelines**
   - Prepare devices properly
   - Separate by type if required
   - Meet any timing requirements

4. **Business Compliance**
   If disposing business equipment:
   - Track all disposals
   - Maintain records
   - Use certified vendors
   - File required reports

## Future Trends

Expect regulations to:
- Become more stringent
- Expand to more device types
- Increase producer responsibility
- Strengthen enforcement

Stay informed: Regulations change frequently!
''';

  static const String _disposalJourneyArticle = '''
# What Happens After You Dispose Your Device?

Ever wondered where your old smartphone or laptop goes after disposal? Let's follow the journey.

## Step 1: Collection

### Drop-Off Centers
Your device is:
- Logged into inventory system
- Sorted by device type
- Checked for data security
- Stored safely

### Pickup Services
Devices are:
- Collected from your location
- Transported in secure vehicles
- Tracked throughout journey
- Delivered to processing facilities

## Step 2: Initial Sorting

At the facility, devices are sorted by:
- Type (phones, laptops, tablets)
- Brand and model
- Condition (working, broken, parts only)
- Material composition

## Step 3: Data Destruction

Before processing:
- Storage drives are removed
- Data is wiped or destroyed
- Hard drives are shredded
- Certificates issued (for businesses)

## Step 4: Testing and Triage

### Working Devices
- Tested for functionality
- Cosmetic assessment
- Graded by condition
- Routed to refurbishment

### Non-Working Devices
- Assessed for repair potential
- Valuable parts extracted
- Routed to material recovery

## Step 5: Refurbishment (If Applicable)

Devices that can be reused:
1. Deep cleaned
2. Repairs made
3. Software installed
4. Quality tested
5. Packaged for resale or donation

## Step 6: Dismantling

Non-reusable devices are:
- Manually disassembled
- Components separated by type
- Hazardous materials isolated
- Valuable parts extracted

### What Gets Separated
- Batteries (special handling)
- Circuit boards (precious metals)
- Plastics (by type)
- Metals (ferrous and non-ferrous)
- Glass (displays)
- Cables and wires

## Step 7: Material Recovery

### Precious Metals
Circuit boards contain:
- Gold (connectors)
- Silver (solder, circuits)
- Copper (wiring)
- Platinum (components)

Recovery process:
1. Boards shredded
2. Chemical processing
3. Smelting
4. Purification
5. Ready for reuse

### Base Metals
Steel, aluminum, and copper are:
- Magnetically separated
- Melted down
- Formed into ingots
- Sold to manufacturers

### Plastics
Different plastics are:
- Sorted by type
- Shredded
- Cleaned
- Pelletized
- Used in new products

## Step 8: Hazardous Material Handling

### Batteries
- Separated by chemistry
- Sent to specialized facilities
- Materials recovered safely
- Toxins neutralized

### Other Hazardous Components
- Mercury (older displays)
- Lead (solder, screens)
- Cadmium (batteries)
- Brominated flame retardants

## Environmental Benefits

### Materials Saved Per 1000 Phones
- 35 kg copper
- 16 kg iron
- 350g silver
- 34g gold
- 15g palladium

### Environmental Impact Reduction
- Reduced mining needs
- Lower carbon emissions
- Less landfill waste
- Prevented toxic contamination

## Where Materials Go

Recovered materials become:
- New electronics
- Automotive parts
- Construction materials
- Jewelry and coins
- Industrial applications

## Certification and Tracking

Reputable facilities provide:
- Chain of custody documentation
- Material recovery reports
- Environmental impact statements
- Compliance certificates

## The Circular Economy

Your disposed device contributes to:
- Reducing need for raw materials
- Creating green jobs
- Supporting sustainable manufacturing
- Protecting the environment

**Your responsible disposal makes this entire cycle possible!**

Next time you dispose of a device, remember: it's not the end, but a transformation into something new.
''';

  // ========================================
  // HELPER METHODS
  // ========================================
  
  /// Get all content (videos + articles)
  static List<LearningContent> getAllContent() {
    return [...videos, ...articles];
  }

  /// Get content by type
  static List<LearningContent> getContentByType(ContentType type) {
    return getAllContent().where((c) => c.type == type).toList();
  }

  /// Get content by category
  static List<LearningContent> getContentByCategory(ContentCategory category) {
    return getAllContent().where((c) => c.category == category).toList();
  }

  /// Get featured content
  static List<LearningContent> getFeaturedContent() {
    return getAllContent().where((c) => c.isFeatured).toList();
  }

  /// Search content
  static List<LearningContent> searchContent(String query) {
    final lowerQuery = query.toLowerCase();
    return getAllContent().where((c) {
      return c.title.toLowerCase().contains(lowerQuery) ||
             c.description.toLowerCase().contains(lowerQuery) ||
             c.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Get content by ID
  static LearningContent? getContentById(String id) {
    try {
      return getAllContent().firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
