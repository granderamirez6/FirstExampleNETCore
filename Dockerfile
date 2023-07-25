# Use the base image from the OpenShift registry
FROM image-registry.openshift-image-registry.svc:5000/granderamirez-6-dev/new-app-example@sha256:d130fcc0950da1e97723698f50788fef727685c528a6346c4507c23a75f84dae

# Set environment variables
ENV DOTNET_STARTUP_PROJECT="app/app.csproj" \
    OPENSHIFT_BUILD_NAME="new-example-10" \
    OPENSHIFT_BUILD_NAMESPACE="granderamirez-6-dev" \
    OPENSHIFT_BUILD_SOURCE="https://github.com/granderamirez6/FirstExampleNETCore/" \
    OPENSHIFT_BUILD_COMMIT="15de6c0d19147291c2427c06f4ce49453c64107e"

# Switch to the root user to copy the application source
USER root

# Copy the application source from the "upload/src" directory to "/tmp/src"
COPY upload/src /tmp/src

# Change ownership of the copied files to user 1001 (this is usually the non-root user used by OpenShift)
RUN chown -R 1001:0 /tmp/src

# Switch back to the non-root user
USER 1001

# Perform the "assemble" step here (if required)

# Add any other necessary steps for your application build

# Continue with the rest of the Dockerfile as needed

# ...

# For example, you may include steps to run the application in the container

# CMD ["dotnet", "app.dll"]
