imbalanced learning is one of the main challenges of classification in real world problems. 
This challenge occurs when the number of examples of the majority class is more than the number of examples of the minority class.
Fraud detection, image segmentation, network intrusion detection, disease detection, etc. are all imbalanced problems.
Therefore, the approach of this research can be used in real world problems.

If you are interested in imbalanced learning, 
you can improve the proposed approach and use its results in your research or in real-world problems.


Lack of diversity in synthetic data and inaccurate approximations of the minority class distribution
are two main challenges with most oversampling techniques. This paper proposes a multimanifold
guided dictionary learning (M2GDL) approach for minority class oversampling. The
proposed approach checks whether synthetic data points are useful and whether minority-class
samples are important for data generation. The approach utilizes a linear combination of multiple
manifolds by leveraging the inherent substructures of the data. Different data manifolds are
constructed from the minority class training data and evaluated using a novel criterion. The
importance of each sample is calculated within each manifold and then weighted according to the
manifolds’ scores. Samples with the highest scores are identified as significant, and their K nearest
neighbors are used to form a data dictionary for generating artificial data. The proposed sample
generation method is achieved through the iterative solution of an optimization problem. Synthetic
samples are then validated based on their proximity to the minority-class combinatorial
manifold.

To run the simulation of this research, you must first install the Matlab toolbox for dimensionality reduction
via https://lvdmaaten.github.io/drtoolbox/. 
In this research, the dimension reduction toolbox was used only for unsupervised linear mapping of imbalanced data,
and the dimension reduction operation was not performed on the data.
Then run the over_sampling_program.m file. 
For each specific dataset, you must execute its loading command and after over-sampling, see the classifier performance criteria.


If you find M2GDL-Multi-Manifold Guided Dictionary Learning based Over-Sampling useful in your research, please consider citing our paper:

M2GDL: Multi-Manifold Guided Dictionary Learning Based Over Sampling and Data Validation for Highly Imbalanced Classification Problems, 
T Feizi, MH Moattar, H Tabatabaee, Journal of  Information Sciences,  Jul 31, 2024.

https://www.sciencedirect.com/science/article/abs/pii/S0020025524011940?dgcid=author
