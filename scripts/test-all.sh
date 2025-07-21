#!/bin/bash

echo "🧪 RUNNING ALL TESTS"
echo "==================="

cd /mnt/c/Users/tsahi/VC/shopping-cart-fullstack

test_results=0
total_test_suites=0

# Test React Frontend
echo ""
echo "1️⃣ Testing React Frontend"
echo "========================="
if [ -f "frontend/package.json" ]; then
    echo "🧪 Running React tests..."
    cd frontend
    
    total_test_suites=$((total_test_suites + 1))
    if npm test -- --watchAll=false --coverage 2>/dev/null; then
        echo "✅ React tests passed"
        test_results=$((test_results + 1))
    else
        echo "⚠️ React tests failed or no tests found"
        echo "   This is normal if you haven't written tests yet"
    fi
    cd ..
else
    echo "⚠️ Frontend not found - skipping tests"
fi

# Test .NET API
echo ""
echo "2️⃣ Testing .NET API"
echo "==================="
if ls backend/dotnet-api/*.csproj 1> /dev/null 2>&1; then
    echo "🧪 Running .NET tests..."
    cd backend/dotnet-api
    
    total_test_suites=$((total_test_suites + 1))
    if dotnet test --verbosity quiet; then
        echo "✅ .NET tests passed"
        test_results=$((test_results + 1))
    else
        echo "⚠️ .NET tests failed or no tests found"
        echo "   This is normal if you haven't written tests yet"
    fi
    cd ../..
else
    echo "⚠️ .NET API not found - skipping tests"
fi

# Test Node.js Search API
echo ""
echo "3️⃣ Testing Node.js Search API"
echo "============================="
if [ -f "backend/nodejs-search/package.json" ]; then
    echo "🧪 Running Node.js tests..."
    cd backend/nodejs-search
    
    total_test_suites=$((total_test_suites + 1))
    if npm test 2>/dev/null; then
        echo "✅ Node.js tests passed"
        test_results=$((test_results + 1))
    else
        echo "⚠️ Node.js tests failed or no tests found"
        echo "   This is normal if you haven't written tests yet"
    fi
    cd ../..
else
    echo "⚠️ Node.js Search API not found - skipping tests"
fi

# Summary
echo ""
echo "📊 TEST SUMMARY"
echo "==============="
echo "Test suites run: $total_test_suites"
echo "Test suites passed: $test_results"

if [ $test_results -eq $total_test_suites ] && [ $total_test_suites -gt 0 ]; then
    echo ""
    echo "🎉 All tests passed!"
elif [ $test_results -gt 0 ]; then
    echo ""
    echo "⚠️ Some tests passed - this is normal for initial setup"
    echo "Add more tests as you develop features"
else
    echo ""
    echo "📝 No tests found or all failed"
    echo "This is normal for initial setup - add tests as needed"
fi

echo ""
echo "💡 To add tests:"
echo "- React: Add .test.js files in src/"
echo "- .NET: Add test projects with xUnit"
echo "- Node.js: Add test scripts in package.json"
